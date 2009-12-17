require 'puppet/rails/host'

class NodeController < ApplicationController
  unloadable

  helper :projects, :initr
  menu_item :initr

  before_filter :find_node, :except => [:new,:list,:get_host_definition,:facts,:scan_puppet_hosts,:unassigned_nodes,:assign_node]
  before_filter :find_project, :only => [:new]
  before_filter :find_optional_project, :only => [:list]
  before_filter :authorize, :except => [:get_host_definition,:list,:facts,:scan_puppet_hosts,:unassigned_nodes,:assign_node]
  before_filter :authorize_global, :only => [:list,:facts]
  before_filter :require_admin, :only => [:scan_puppet_hosts,:unassigned_nodes,:assign_node]
  
  layout 'nested'
  
  skip_before_filter :check_if_login_required, :only => [ :get_host_definition ]
  session :off, :only => [ :get_host_definition ]

  # skip ssl_requirement's plugin before_filter, in case it is
  # pressent in redmine, for get_host_definition
  skip_before_filter :ensure_proper_protocol, :only => [:get_host_definition]  
  
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
      if User.current.admin?
        @subprojects = Project.all.sort
      else
        User.current.projects.sort.each do |p|
          @subprojects << p
        end
      end
    else
      @subprojects = @project.descendants.visible.sort
    end
  end

  def facts
    @fact=params[:id]
    if User.current.admin?
      @nodes=Project.all.collect {|p| p.nodes }.flatten.compact.sort
    else
      @nodes=User.current.projects.collect {|p| p.nodes }.flatten.compact.sort
    end
    @facts={}
    @nodes.each do |n|
      @facts[n] = n.puppet_fact(params[:id]) unless n.puppet_fact(params[:id]).nil?
    end
  end

  def destroy
    @node.destroy
    redirect_to :action => 'list', :id => @project
  end

  def get_host_definition
    if request.remote_ip == '127.0.0.1' or Setting.plugin_initr['puppetmaster_ip'].gsub(/ /,'').split(",").include?(request.remote_ip)
      begin
        node = Initr::Node.find(params[:hostname])
        render :text => YAML.dump(node.parameters)
      rescue ActiveRecord::RecordNotFound
        render :text => "Unknown hostname '#{params[:hostname]}'\n", :status => 404
        logger.error "Unknown hostname '#{params[:hostname]}'."
      end
    else
      render :text => "Not allowed from your IP #{request.remote_ip}\n", :status => 403
      logger.error "Not allowed from IP #{request.remote_ip} (must be from #{Setting.plugin_initr['puppetmaster_ip']}).\n"
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

  # import hosts from puppet database
  def scan_puppet_hosts
    @hosts_exist = Array.new
    @hosts_new = Array.new
    hosts = Puppet::Rails::Host.find :all
    hosts.each do |host|
      if Initr::Node.find_by_name host.name
        @hosts_exist << host.name
      else
        @hosts_new << host.name
        node = Initr::Node.new
        node.name = host.name
        node.save
      end
    end
  end

  def unassigned_nodes
    @projects = Project.find :all
    @nodes = Initr::Node.find :all, :order => "project_id, name"
  end

  def assign_node
    @node=Initr::Node.find params[:id]
    if @node.update_attributes(params[:node])
      flash[:notice] = 'Initr::Node assigned to project.'
    else
      flash[:error] = 'Error in node-project assignation.'
    end
    redirect_to :action => 'unassigned_nodes'
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
