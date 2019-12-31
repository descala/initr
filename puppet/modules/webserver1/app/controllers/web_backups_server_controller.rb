class WebBackupsServerController < InitrController

  menu_item :initr
  before_action :find_web_backups_server
  before_action :authorize

  def configure
    @html_title=[@node.fqdn, @klass.name]
    if request.patch?
      if @klass.update_attributes params[:web_backups_server]
        flash[:notice] = 'Configuration saved'
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
