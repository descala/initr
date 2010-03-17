require 'puppet/rails/host'

class NodeController < ApplicationController
  unloadable

  helper :projects, :initr
  menu_item :initr

  before_filter :find_node, :except => [:new,:list,:get_host_definition,:facts,:scan_puppet_hosts,:unassigned_nodes,:assign_node,:new_template]
  before_filter :find_project, :only => [:new]
  before_filter :find_optional_project, :only => [:list]
  before_filter :authorize, :except => [:get_host_definition,:list,:facts,:scan_puppet_hosts,:unassigned_nodes,:assign_node,:new_template]
  before_filter :authorize_global, :only => [:list,:facts,:new_template]
  before_filter :require_admin, :only => [:scan_puppet_hosts,:unassigned_nodes,:assign_node]
  
  layout 'nested'
  
  skip_before_filter :check_if_login_required, :only => [ :get_host_definition ]
  session :off, :only => [ :get_host_definition ]

  # skip ssl_requirement's plugin before_filter, in case it is
  # pressent in redmine, for get_host_definition
  skip_before_filter :ensure_proper_protocol, :only => [:get_host_definition]  
  
  def new
    # find_project
    @node_instance = Initr::NodeInstance.new(params[:node_instance])
    @node_instance.user = User.current
    @node_instance.project = @project
    if request.post? && @node_instance.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action => 'list', :id => @project
    end
  end

  def new_template
    # caution: @template is an internal rails variable, don't use it
    @node_template = Initr::NodeTemplate.new(params[:node_template])
    @node_template.user = User.current
    @node_template.project = Project.find(params[:id]) if params[:id]
    if request.post? && @node_template.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to :controller=>'klass', :action=>'list', :id=>@node_template
    end
  end

  def list
    @nodes = {}
    @templates = {}
    @templates_without_project = []

    if @project.nil?    # list all visible nodes
      if User.current.admin?
        Project.all.each do |proj|
          @nodes[proj] = proj.node_instances
        end
      else
        User.current.projects.sort.each do |proj|
          @nodes[proj] = proj.node_instances if User.current.allowed_to?(:view_nodes, proj)
        end
      end
    else                # list all nodes of a project
      @nodes[@project] = @project.node_instances if User.current.allowed_to?(:view_nodes, @project)
      @project.descendants.visible.sort.each do |p|
        @nodes[p] = p.node_instances if User.current.allowed_to?(:view_nodes, p)
      end
    end

    # own nodes
    User.current.node_instances.each do |n|
      # check for "View own nodes" permission for "non-member" role
      next unless n.visible_by?(User.current)
      if (@project.nil? and !@nodes.keys.include? n.project) || (!@nodes.keys.include? n.project and n.project == @project)
        @nodes[n.project] ||= []
        @nodes[n.project] << n
      end
    end

    # node templates with project
    @nodes.keys.each do |p|
      @templates[p] = p.node_templates if p.node_templates.any?
    end

    (render_403; return) if (@project && !User.current.member_of?(@project) && !@nodes.any? && !@templates.any?)

    # node templates without project
    unless @project
      User.current.node_templates.each do |t|
        next unless t.visible_by?(User.current)
        unless t.project.is_a? Initr::FakeProject
          @templates[t.project] ||= []
          @templates[t.project] << t unless @templates[t.project].include? t
        else
          @templates_without_project << t
        end
      end
    end
  end

  def facts
    @fact=params[:id]
    if User.current.admin?
      nodes=Project.all.collect {|p| p.node_instances }.flatten.compact
    else
      nodes=User.current.projects.collect { |p|
        p.node_instances if User.current.allowed_to?(:view_nodes, p)
      }.flatten.compact
      User.current.node_instances.each do |n|
        nodes << n if !nodes.include?(n) && n.visible_by?(User.current)
      end
    end
    @facts={}
    nodes.each do |n|
      @facts[n] = n.puppet_fact(params[:id]) unless n.puppet_fact(params[:id]).nil?
    end
  end

  def destroy
    @node.destroy
    redirect_to :action => 'list', :id => @project
  end
  
  def destroy_exported_resources
    @node.destroy_exported_resources
    redirect_to :controller => 'klass', :action => 'list', :id => @node
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
    @projects = Project.all
    @users = User.all
    @node_instances = Initr::NodeInstance.find :all, :order => "project_id, name"
    @node_templates = Initr::NodeTemplate.find :all, :order => "project_id, name"
  end

  def assign_node
    @node=Initr::Node.find params[:id]
    if @node.update_attributes(params[:node])
      flash[:notice] = 'Update successfull'
    else
      flash[:error] = 'Update error'
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
