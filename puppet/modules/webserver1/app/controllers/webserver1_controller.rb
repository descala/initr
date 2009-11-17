class Webserver1Controller < ApplicationController
  unloadable

  layout 'nested'
  menu_item :initr
  
  before_filter :find_webserver, :except => [:edit_domain,:rm_domain]
  before_filter :find_domain, :only => [:edit_domain,:rm_domain]
  before_filter :authorize

  def configure
    if request.post?
      if @webserver.update_attributes params[:webserver1]
          flash[:notice] = 'Configuration saved'
          redirect_to :controller => 'klass', :action => 'list', :id => @node
      else
        render :action => 'configure'
      end
    end
  end

  def add_domain
    @domain=Initr::Webserver1Domain.new(params[:webserver1_domain])
    @domain.webserver1 = @webserver
    if request.post?
      if @domain.save
        flash[:notice] = 'Domain saved'
        redirect_to :action => 'configure', :id => @webserver
      else
        render :action => 'add_domain'
      end
    end
  end

  def edit_domain
    if request.post?
      if @domain.update_attributes(params["webserver1_domain"])
        redirect_to :action => 'configure', :id => @webserver
      else
        render :action => 'edit_domain'
      end
    end
  end

  def rm_domain
    @domain.destroy if request.post?
    redirect_to :action => 'configure', :id => @webserver
  end
  
  private

  def find_webserver
    @webserver = Initr::Webserver1.find params[:id]
    @node = @webserver.node
    @project = @node.project
  end

  def find_domain
    @domain = Initr::Webserver1Domain.find params[:id]
    @webserver = @domain.webserver
    @node = @webserver.node
    @project = @node.project
  end
  
end
