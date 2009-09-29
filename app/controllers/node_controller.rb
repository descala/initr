require 'puppet/rails/host'

class NodeController < ApplicationController
  unloadable

  helper :projects, :initr
  menu_item :initr

  before_filter :find_node, :except => [:new,:list,:get_host_definition]
  before_filter :find_project, :only => [:new]
  before_filter :find_optional_project, :only => [:list]
  before_filter :authorize, :except => [:get_host_definition,:list]
  before_filter :authorize_global, :only => [:list]
  
  layout 'nested'
  
  skip_before_filter :check_if_login_required, :only => [ :get_host_definition ]
  session :off, :only => [ :get_host_definition ]

  
  def new
    # find_project
    @node = Initr::Node.new(params[:node])
    @node.project = @project
    if request.post? && @node.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action => 'list', :id => @project
    end
  end

  def list
    if @project.nil?
      @subprojects = []
      User.current.projects.each do |p|
        @subprojects << p
      end
    else
      @subprojects = @project.descendants.visible
    end
  end

  def destroy
    @node.destroy
    redirect_to :action => 'list', :id => @project
  end

  def get_host_definition
    if request.remote_ip == '127.0.0.1' or request.remote_ip == Setting.plugin_initr_plugin['puppetmaster_ip']
      begin
        node = Initr::Node.find(params[:hostname])
        render :text => YAML.dump(node.parameters)
      rescue ActiveRecord::RecordNotFound
        render :text => "Unknown hostname '#{params[:hostname]}'\n", :status => 404
        logger.error "Unknown hostname '#{params[:hostname]}'."
      end
    else
      render :text => "Not allowed from your IP #{request.remote_ip}\n", :status => 403
      logger.error "Not allowed from IP #{request.remote_ip} (must be from #{Setting.plugin_initr_plugin['puppetmaster_ip']}).\n"
    end
  end

  def getip
    xff=request.env['HTTP_X_FORWARDED_FOR'].split(",").first
    unless xff.blank?
      render :text => "#{xff}\n"
    else
      render :text => "#{request.env['REMOTE_ADDR']}\n"
    end
  end

  private

  def find_node
    @node = Initr::Node.find params[:id]
    @project = @node.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def find_project
    begin
      @project = Project.find(params[:id])
      logger.info "Project #{@project.name}"
    rescue ActiveRecord::RecordNotFound
      render_404
    end
  end
  
  def find_optional_project
    return true unless params[:id]
    @project = Project.find(params[:id])
    authorize
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end
