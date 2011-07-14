class NagiosServerController < InitrController
  unloadable

  menu_item :initr
  before_filter :find_nagios_server
  before_filter :authorize

  def configure
    @html_title=[@node.fqdn, @klass.name]
    @user_projects = Project.all.collect {|proj|
      proj if User.current.projects.include? proj or User.current.admin?
    }.compact.sort
    if request.post?
      if @klass.update_attributes(params[:nagios_server])
        flash[:notice] = 'Configuration successfully updated.'
        redirect_to :controller => 'klass', :action => 'list', :id => @node
      else
        render :action => 'configure'
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
