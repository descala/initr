# "My DNS" — self-service surface letting a logged-in user edit only the bind
# zones assigned to them (via Initr::BindZoneManager), and nothing else.
# The gate is per-zone ownership (Initr::BindZone#editable_by?), not project
# membership — the controller never checks it (zones may span many projects).
class MyZonesController < InitrController

  layout 'base'
  menu_item :my_dns

  before_action :require_login
  # index: enforce the declared :edit_own_bind_zones permission (403 vs. empty list).
  before_action :authorize_global, :only => [:index]
  before_action :find_zone,      :only => [:edit, :update]
  before_action :authorize_zone, :only => [:edit, :update]

  def index
    @html_title = ['My DNS']
    @bind_zones = my_zones.order(:domain)
  end

  def edit
    @html_title = ['My DNS', @bind_zone.domain]
    @zone_header = render_to_string(:partial => 'bind/zone_header', :locals => { :zone => @bind_zone })
  end

  def update
    # Only the records text are editable here — never the TTL, domain,
    # registrant or whois data. named_checkzone (a BindZone validation) blocks a
    # syntactically broken save; the serial bump and puppetrun fire on success.
    if @bind_zone.update(:zone => params.dig(:bind_zone, :zone))
      flash[:notice] = l(:notice_successful_update)
      redirect_to :action => 'index'
    else
      @zone_header = render_to_string(:partial => 'bind/zone_header', :locals => { :zone => @bind_zone })
      render :action => 'edit'
    end
  end

  private

  # Live zones (skip orphans whose bind klass was deleted) managed by the user.
  def my_zones
    Initr::BindZone
      .joins(:managers)
      .where(:users => { :id => User.current.id })
      .where(:bind_id => Initr::Bind.select(:id))
  end

  def find_zone
    @bind_zone = my_zones.find_by(:id => params[:id])
    render_404 unless @bind_zone
  end

  def authorize_zone
    deny_access unless @bind_zone.editable_by?(User.current)
  end
end
