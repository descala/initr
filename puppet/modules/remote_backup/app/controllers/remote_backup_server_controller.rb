class RemoteBackupServerController < InitrController
  unloadable

  menu_item :initr
  before_filter :find_remote_backup_server
  before_filter :authorize

  def configure
    @html_title=[@node.fqdn, @klass.name]
    if request.post?
      if @klass.update_attributes params[:remote_backup_server]
        flash[:notice] = 'Configuration saved'
        redirect_to :controller => 'klass', :action => 'list', :id => @node
      else
        render :action => 'configure'
      end
    end
  end

  private

  def find_remote_backup_server
    @klass = Initr::RemoteBackupServer.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

end
