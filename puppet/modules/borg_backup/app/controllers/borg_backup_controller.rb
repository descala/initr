class BorgBackupController < InitrController

  menu_item :initr

  before_action :find_borg_backup
  before_action :authorize

  def configure
    @html_title=[@node.fqdn, @klass.name]
    if request.patch?
      params['borg_backup'] ||= {}
      if @klass.update(params['borg_backup'])
        flash.now[:notice] = 'Configuration saved'
      end
    else
      @klass.repository = "#{@node.fqdn.gsub('.','_')}@borg:repo" if @klass.repository.empty?
      @klass.borg_passphrase = (`pwgen 10 1`.strip rescue nil) if @klass.borg_passphrase.empty?
    end
  end

  private

  def find_borg_backup
    @klass = Initr::BorgBackup.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

end
