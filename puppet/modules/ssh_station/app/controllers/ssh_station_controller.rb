class SshStationController < InitrController

  menu_item :initr
  before_action :find_ssh_station, :except => [ :del_port, :get_user_nodes, :edit_port, :my_ssh_config ]
  before_action :find_port, :only => [ :del_port, :edit_port ]
  before_action :find_project, :only => [ :my_ssh_config ]
  before_action :authorize, :except => [:get_user_nodes]

  def configure
    @html_title=[@node.fqdn, @klass.name]
    @ssh_station_servers = ssh_station_servers_for_current_user
    if request.post?
      if @klass.update(params[:initr_ssh_station])
        flash[:notice] = 'Configuration successfully updated.'
        redirect_to :action => 'configure'
      else
        render :action => 'configure'
      end
    end
  end

  def add_port
    @port=Initr::SshStationPort.new(params[:initr_ssh_station_port])
    @port.ssh_station = @klass
    if request.post?
      if @port.save
        flash[:notice] = 'Port redirection saved'
        redirect_to :action => 'configure', :id => @klass
      else
        render :action => 'add_port'
      end
    end
  end

  def edit_port
    if request.patch?
      if @port.update(params[:initr_ssh_station_port])
        flash[:notice] = 'Port successfully updated.'
        redirect_to :action => 'configure', :id => @klass
      else
        render :action => 'edit_port'
      end
    end
  end

  def del_port
    @port.destroy if request.post?
    redirect_to :action => 'configure', :id => @klass
  end

  def my_ssh_config
    user_projects = User.current.projects
    @ssh_stations = Initr::SshStation.all.collect { |ss|
      ss if user_projects.include?(ss.node.project) and
        ss.ssh_station_server and
        !ss.node.is_a?(Initr::NodeTemplate) and
        !ss.node.klasses.collect{|k|k.name}.include?('ssh_station::server')
    }.compact
  end

  private

  def ssh_station_servers_for_current_user
    user_projects = User.current.projects
    user_projects = Project.all if User.current.login == "admin"
    Initr::SshStationServer.all.collect { |sss|
      sss if user_projects.include? sss.node.project rescue nil
    }.compact
  end

  def find_ssh_station
    @klass = Initr::SshStation.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

  def find_port
    @port = Initr::SshStationPort.find params[:id]
    @klass = @port.ssh_station
    @node = @klass.node
    @project = @node.project
  end

end
