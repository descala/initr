class RemoteBackupController < InitrController

  menu_item :initr
  before_filter :find_remote_backup
  before_filter :authorize

  def configure
    @html_title=[@node.fqdn,@klass.name]
    #TODO: filtrar visibles
    @remote_backup_servers = Initr::RemoteBackup.remote_backup_servers_for_current_user.collect { |rbs|
      [rbs.node.fqdn, rbs.id]
    }
    if request.patch?
      if @klass.update_attributes params[:remote_backup]
        flash[:notice] = 'Configuration saved'
      end
    end
  end

  private

  def find_remote_backup
    @klass = Initr::RemoteBackup.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

end
