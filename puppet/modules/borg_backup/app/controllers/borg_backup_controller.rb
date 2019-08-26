class BorgBackupController < InitrController

  menu_item :initr

  before_filter :find_borg_backup
  before_filter :authorize

  def configure
    @html_title=[@node.fqdn, @klass.name]
    if request.patch?
      params['borg_backup'] ||= {}
      if @klass.update_attributes(params['borg_backup'])
        flash.now[:notice] = 'Configuration saved'
      end
    end
  end

  private

  def find_borg_backup
    @klass = Initr::BorgBackup.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

end
