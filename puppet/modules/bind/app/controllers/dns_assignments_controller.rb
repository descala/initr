# Central DNS assignment page (admin only): pick a self-service user, then manage
# which bind zones they may edit. Shows the user's currently assigned zones and a
# search-to-add field. This is the only place Initr::BindZoneManager join rows are
# created;
#
# Access is admin-only (require_admin); the link lives in the Administration
# sidebar (:admin_menu, registered in the bind module init.rb).
class DnsAssignmentsController < InitrController

  layout 'admin'
  menu_item :dns_assignments

  before_action :require_admin
  before_action :find_user, :only => [:search, :add_zone, :remove_zone]

  def index
    @html_title = [l(:label_dns_assignments)]
    @users = assignable_users
    @user  = User.find_by(:id => params[:user_id]) if params[:user_id].present?
    @bind_zones = managed_zones if @user
  end

  # JSON autocomplete source for the "add zone" field: live zones whose domain
  # matches the query and that this user does not already manage. Capped so a
  # broad query can't return the whole table.
  def search
    query = params[:q].to_s.strip
    zones =
      if query.blank?
        Initr::BindZone.none
      else
        live_zones
          .where("domain LIKE ?", "%#{query}%")
          .where.not(:id => managed_zone_ids)
          .limit(20)
      end

    render :json => zones.map { |zone|
      { :id => zone.id, :domain => zone.domain, :context => zone_context(zone) }
    }
  end

  def add_zone
    zone = live_zones.find_by(:id => params[:zone_id])
    if zone
      # find_or_create_by is idempotent against the unique [zone, user] index.
      Initr::BindZoneManager.find_or_create_by(:bind_zone_id => zone.id, :user_id => @user.id)
      flash[:notice] = l(:notice_successful_update)
    else
      flash[:error] = l(:label_no_zones_assigned)
    end
    redirect_to :action => 'index', :user_id => @user.id
  end

  def remove_zone
    Initr::BindZoneManager
      .where(:bind_zone_id => params[:zone_id], :user_id => @user.id)
      .destroy_all
    flash[:notice] = l(:notice_successful_update)
    redirect_to :action => 'index', :user_id => @user.id
  end

  private

  def find_user
    @user = User.find_by(:id => params[:user_id])
    render_404 unless @user
  end

  # Only users who can actually use a self-service assignment, i.e. those holding
  # the global :edit_own_bind_zones permission. Assigning a zone to anyone else
  # is inert: Initr::BindZone#editable_by? requires that same permission. Using
  # the identical allowed_to?(:global) check keeps this list consistent with the
  # real gate.
  def assignable_users
    User.active.sorted.select do |user|
      user.allowed_to?(:edit_own_bind_zones, nil, :global => true)
    end
  end

  # Live zones only — skip orphans whose bind klass was deleted (see CLAUDE.md:
  # a BindZone can outlive its bind, leaving bind_id pointing at nothing).
  def live_zones
    Initr::BindZone.where(:bind_id => Initr::Bind.select(:id)).order(:domain)
  end

  def managed_zone_ids
    Initr::BindZoneManager.where(:user_id => @user.id).pluck(:bind_zone_id)
  end

  def managed_zones
    live_zones.where(:id => managed_zone_ids)
  end

  # Human context to disambiguate look-alike domains (the domain collation is
  # accent-insensitive, so identify the owning host/klass, not just the name).
  def zone_context(zone)
    zone.bind&.node&.fqdn || zone.bind&.name
  end
end
