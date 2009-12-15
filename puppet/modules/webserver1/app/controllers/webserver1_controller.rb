class Webserver1Controller < ApplicationController
  unloadable

  layout 'nested'
  helper :initr
  menu_item :initr

  before_filter :find_webserver, :except => [:edit_domain,:rm_domain]
  before_filter :find_domain, :only => [:edit_domain,:rm_domain]
  before_filter :authorize

  def configure
    if request.post?
      if @klass.update_attributes params[:webserver1]
          flash[:notice] = 'Configuration saved'
          redirect_to :action => 'configure'
      else
        render :action => 'configure'
      end
    end
  end

  def add_domain
    @web_backups_servers = Initr::Webserver1.backup_servers_for_current_user.collect {|wbs| [wbs.node.fqdn, wbs.id] }
    @domain=Initr::Webserver1Domain.new(params[:webserver1_domain])
    @domain.webserver1 = @klass
    if request.post?
      if @domain.save
        flash[:notice] = 'Domain saved'
        redirect_to :action => 'configure', :id => @klass
      else
        render :action => 'add_domain'
      end
    end
  end

  def edit_domain
    @web_backups_servers = Initr::Webserver1.backup_servers_for_current_user.collect {|wbs| [wbs.node.fqdn, wbs.id] }
    # check if we have a name server
    @bind = Initr::Bind.for_node @node
    @bind_zone = @bind.bind_zones.find(:first, :conditions=>["domain=?",@domain.name]) if @bind
    if request.post?
      if @domain.update_attributes(params["webserver1_domain"])
        redirect_to :action => 'configure', :id => @klass
      else
        render :action => 'edit_domain'
      end
    end
  end

  def rm_domain
    @domain.destroy if request.post?
    redirect_to :action => 'configure', :id => @klass
  end

  private

  def find_webserver
    @klass = Initr::Webserver1.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

  def find_domain
    @domain = Initr::Webserver1Domain.find params[:id]
    @klass = @domain.webserver
    @node = @klass.node
    @project = @node.project
  end

end
