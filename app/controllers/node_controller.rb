class NodeController < InitrController

  menu_item :initr
  helper :projects, :initr

  before_action :find_node,
    :except => [:new,:list,:get_host_definition,:facts,:scan_puppet_hosts,:unassigned_nodes,:assign_node,:new_template,:store_report,:report,:resource,:get_services]
  before_action :find_project, :only => [:new]
  before_action :find_optional_project, :only => [:list]
  before_action :find_report, :only => [:report]
  before_action :authorize,
    :except => [:get_host_definition,:list,:facts,:scan_puppet_hosts,:unassigned_nodes,:assign_node,:new_template,:store_report,:get_services]
  before_action :authorize_global, :only => [:list,:facts,:new_template,:get_services]
  before_action :require_admin, :only => [:scan_puppet_hosts,:unassigned_nodes,:assign_node]

  skip_before_action :check_if_login_required, :only => [ :get_host_definition, :store_report ]

  protect_from_forgery :except=>[:store_report]

  accept_api_auth :get_services

  ## TODO redmine2
  ## avoids storing the report data in the log files
  ##filter_parameter_logging :report

  def new
    if Setting.plugin_initr["puppetmaster"].blank? or Setting.plugin_initr["puppetmaster_port"].blank?
      if User.current.admin?
        flash[:error] = "Configure initr first"
        redirect_to "/settings/plugin/initr"
      else
        render "initr/unconfigured"
      end
      return
    end
    @node = Initr::NodeInstance.new
    @node.user = User.current
    @node.project = @project
    @node.name = SecureRandom.hex(20)
    @node.save!
    redirect_to :controller => 'klass', :action => 'list', :id => @node
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
      if (@project.nil? and (!@nodes[n.project] or !@nodes[n.project].include? n)) ||
         (n.project == @project and (!@nodes[@project] or !@nodes[@project].include? n))
        @nodes[n.project] ||= []
        @nodes[n.project] << n
      end
    end

    # node templates with project
    @nodes.keys.each do |p|
      next if p.nil? # skip unassigned nodes
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
    # TODO: more efficent with
    # Initr.puppetdb.request('',"facts[value] {name = '#{params[:id]}'}")
    nodes.each do |n|
      @facts[n] = n.fact(params[:id]) unless n.fact(params[:id]).nil?
    end
  end

  def destroy
    @node.destroy
    if User.current.allowed_to?(:view_nodes, @project)
      redirect_to :action => 'list', :id => @project
    else
      redirect_to :action => 'list'
    end
  end

  def destroy_exported_resources
    # (render_403; return) unless @node && @node.editable_by?(User.current)
    # @node.destroy_exported_resources
    flash[:notice] = "TODO: destroy_exported_resources not implemented"
    redirect_to :controller => 'klass', :action => 'list', :id => @node, :tab => 'exported_resources'
  end

  def get_host_definition
    if !Rails.env.production? or request.remote_ip == '127.0.0.1' or Setting.plugin_initr['puppetmaster_ip'].gsub(/ /,'').split(",").include?(request.remote_ip)
      node = Initr::NodeInstance.find_by_name(params[:hostname])
      if node
        render plain: YAML.dump(node.parameters)
      else
        render plain: "Unknown hostname '#{params[:hostname]}'\n", :status => 404
        logger.error "Unknown hostname '#{params[:hostname]}'."
      end
    else
      render plain: "Not allowed from your IP #{request.remote_ip}\n", :status => 403
      logger.error "Not allowed from IP #{request.remote_ip} (must be from #{Setting.plugin_initr['puppetmaster_ip']}).\n"
    end
  end

  def getip
    xff=request.env['HTTP_X_FORWARDED_FOR'].split(",").first
    unless xff.blank?
      render plain: "#{xff}\n"
    else
      render plain: "#{request.env['REMOTE_ADDR']}\n"
    end
  end

  # import hosts from puppet database
  def scan_puppet_hosts
    @hosts_exist = Array.new
    @hosts_new = Array.new
    hosts = Puppet::Rails::Host.all
    hosts.each do |host|
      if Initr::NodeInstance.find_by_name host.name
        @hosts_exist << host.name
      else
        @hosts_new << host.name
        node = Initr::NodeInstance.new
        node.name = host.name
        node.save(:validate => false)
      end
    end
  end

  def unassigned_nodes
    @projects = Project.all.sort
    @users = User.where(:status=>User::STATUS_ACTIVE).sort
    @node_instances = Initr::NodeInstance.all.order("project_id, name")
    @node_templates = Initr::NodeTemplate.all.order("project_id, name")
  end

  def assign_node
    @node=Initr::Node.find params[:id]
    @node.project_id = params[:node][:project_id] if params[:node][:project_id]
    @node.user_id    = params[:node][:user_id]    if params[:node][:user_id]
    if @node.save
      flash[:notice] = 'Update successfull'
    else
      flash[:error] = "Update error: #{@node.errors.full_messages}"
    end
    redirect_to :action => 'unassigned_nodes'
  end

  def store_report
    if request.remote_ip == '127.0.0.1' or Setting.plugin_initr['puppetmaster_ip'].gsub(/ /,'').split(",").include?(request.remote_ip)
      respond_to do |format|
        format.yml {
          if Initr::Report.import request.body
            render plain: "Imported report", :status => 200 and return
          else
            render plain: "Failed to import report", :status => 500
          end
        }
      end
    else
      render plain: "Not allowed from your IP #{request.remote_ip}\n", :status => 403
      logger.error "Not allowed from IP #{request.remote_ip} (must be from #{Setting.plugin_initr['puppetmaster_ip']}).\n"
    end
  end

  def delete_report
    #TODO
  end

  def get_services
    @services = []
    nodes = Project.all.collect {|p| p.node_instances }.flatten.compact
    nodes.each do |n|
      unless n.facts["services_list"].blank?
        services = JSON.parse n.facts["services_list"]
        services.each do |s|
          unless s.empty?
            @services << s
          end
        end
      end
    end

    @services.sort_by! {|h| h["service_id"]}
    @services.sort_by! {|h| h["service"]}

    respond_to do |format|
      format.html {render "get_nodes"}
      format.json {render json: @services.to_json}
      format.csv do
        require 'csv'
        # afegir columnes
        columns = ["service", "service_id", "host", "client_name"]
        @services.each do |service|
          service.keys.each do |key|
            columns << key unless columns.include?(key)
          end
        end
        # genera csv posant els camps a columnes corresponents
        csv_string = CSV.generate do |csv|
          line = []
          columns.each do |column|
            line << column
          end
          csv << line
          @services.each do |service|
            line = []
            columns.each do |column|
              found = false
              service.each do |key, value|
                if column == key
                  found = true
                  line << value
                end
              end
              line << '-' unless found
            end
            csv << line
          end
        end
        render plain: csv_string
      end
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
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_report
    @report = Initr::Report.find params[:id]
    @node = @report.node
    @project = @node.project
  end

end
