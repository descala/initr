class MuninController < InitrController

  menu_item :initr
  before_action :find_munin,   :except => [:graphs]
  before_action :find_project, :only => [:graphs]
  before_action :authorize

  def index
    # TODO: use munin_server url
    @html_title = [@node.fqdn, "graphics"]
    @munin_server = @node.klasses.find_by_type("Initr::Munin").server.node rescue nil
    render :text => "no server defined" if @munin_server.nil?
    @munin_klass = Initr::Munin.for_node(@node)
    @graphs = @node.fact("munin_graphs","").split(",").sort
    if params['period'].nil? or params['period'] == "day" or params['period'] == "week"
      @period=["day","week"]
    else
      @period=["month","year"]
    end
  end

  def configure
    @html_title=[@node.fqdn, @klass.name]
    @munin_servers = munin_servers_for_current_user
    if request.patch?
      if @klass.update_attributes params[:munin]
        redirect_to :controller => "klass", :action => "list", :id => @node
      else
        render :action => "configure", :id => @klass
      end
    end
  end

  # show all graphs of same type
  def graphs
    @name = params[:graph]
    @period = params[:period]
    @munins = munins_for_current_user
  end

  private

  def munins_for_current_user
    user_projects = User.current.projects
    Initr::Munin.all.collect { |m|
      mgraphs = m.node.fact('munin_graphs','').split(',')
      m if user_projects.include?(m.node.project) and mgraphs.include?(@name)
    }.compact.sort {|a,b| a.node.fqdn <=> b.node.fqdn }
  end

  def munin_servers_for_current_user
    user_projects = User.current.projects
    Initr::MuninServer.all.collect { |ms|
      ms if user_projects.include? ms.node.project
    }.compact
  end

  def find_munin
    @klass = Initr::Munin.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

  def find_project
    @project = Project.find params[:id]
  end

end
