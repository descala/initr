class NagiosServerController < InitrController

  menu_item :initr
  before_filter :find_nagios_server
  before_filter :authorize

  def configure
    @html_title=[@node.fqdn, @klass.name]
    @user_projects = Project.all.collect {|proj|
      proj if User.current.projects.include? proj or User.current.admin?
    }.compact.sort
    if request.put?
      if @klass.update_attributes(params[:nagios_server])
        flash[:notice] = 'Configuration successfully updated.'
      end
    end
  end

  private

  def find_nagios_server
    @klass = Initr::NagiosServer.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

end
