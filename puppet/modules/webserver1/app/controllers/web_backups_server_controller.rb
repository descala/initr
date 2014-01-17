class WebBackupsServerController < InitrController
  unloadable

  menu_item :initr
  before_filter :find_web_backups_server
  before_filter :authorize

  def configure
    @html_title=[@node.fqdn, @klass.name]
    if request.post? or request.put?
      if @klass.update_attributes params[:web_backups_server]
          flash[:notice] = 'Configuration saved'
          redirect_to :controller => 'klass', :action => 'list', :id => @node
      else
        render :action => 'configure'
      end
    end
  end

  private

  def find_web_backups_server
    @klass = Initr::WebBackupsServer.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

end
