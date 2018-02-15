class BindController < InitrController

  menu_item :initr
  before_filter :find_bind, :except => [:edit_zone,:destroy_zone]
  before_filter :find_bind_zone, :only => [:edit_zone,:destroy_zone]
  before_filter :authorize

  def configure
    @html_title=[@node.fqdn, @klass.name]
    @eligible_masters = eligible_masters
    if request.patch?
      params["bind"] ||= {}
      if @klass.update_attributes(params["bind"])
        flash[:notice]='Configuration saved'
      end
    else
      respond_to do |format|
        format.html
        format.csv do
          export = CSV.generate(
            :headers => ["Name","Notes","Invoice Type","Client","Domain owner","Expire date","Active DNS"],
            :write_headers => true ) do |csv|
            @klass.bind_zones.sort.each do |z|
              csv << [
                z.domain,
                [z.info,(z.invoice.number rescue nil)].join(' '),
                (z.invoice.class rescue nil),
                (z.invoice.client.name rescue nil),
                z.registrant,
                z.expires_on,
                z.active_ns
              ]
            end
          end
          send_data(export, :type => 'text/csv; header=present', :filename => 'domains.csv')
        end
      end
    end
  end

  def add_zone
    @bind_zone = Initr::BindZone.new(params[:bind_zone])
    @bind_zone.bind = @klass
    @zone_header = render_to_string(:partial=>'zone_header',:locals=>{:zone=>@bind_zone})
    if request.post?
      if @bind_zone.save
        flash[:notice]="Bind zone saved"
        redirect_to :action => 'configure', :id => @klass, :anchor => @bind_zone.domain
      else
        render :action=>"add_zone"
      end
    end
  end

  def edit_zone
    @zone_header = render_to_string(:partial=>'zone_header',:locals=>{:zone=>@bind_zone})
    if request.patch?
      if @bind_zone.update_attributes(params[:bind_zone])
        @bind_zone.query_registry
        @bind_zone.update_active_ns
        @bind_zone.save
        flash[:notice]="Bind zone saved"
        redirect_to :action => 'configure', :id => @klass, :anchor => @bind_zone.domain
      else
        render :action => 'edit_zone'
      end
    end
  end

  def destroy_zone
    @bind_zone.destroy if request.post?
    redirect_to :action => 'configure', :id => @klass, :anchor => 'top'
  end

  def add_master
    if request.post?
      @klass.masters << Initr::Bind.find(params[:master_id])
      @klass.save
    end
  ensure
    @eligible_masters = eligible_masters
    render :partial => 'masters'
  end

  def remove_master
    if request.post?
      @klass.masters.delete(Initr::Bind.find(params[:master_id]))
      @klass.save
    end
  ensure
    @eligible_masters = eligible_masters
    render :partial => 'masters'
  end

  def update_active_ns
    @klass.update_active_ns
    flash[:notice]="Updated Active NS"
    redirect_to :action => 'configure', :id => @klass
  end

  def query_registry
    @klass.query_registry
    flash[:notice]="Registry information has been updated"
    redirect_to :action => 'configure', :id => @klass
  end

  def link_to_invoices
    num = @klass.link_to_invoices
    flash[:notice]="#{num} invoice links have been updated"
    redirect_to :action => 'configure', :id => @klass
  end

  private

  def eligible_masters
    user_projects = User.current.projects
    user_projects = Project.all if User.current.login == "admin"
    Initr::Bind.all.collect { |bind|
      next if @klass.masters.include?(bind) or bind == @klass
      bind if bind.node and user_projects.include?(bind.node.project)
    }.compact
  end

  def find_bind
    @klass = Initr::Bind.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

  def find_bind_zone
    @bind_zone = Initr::BindZone.find params[:id]
    @klass = @bind_zone.bind
    @node = @klass.node
    @project = @node.project
  end

end
