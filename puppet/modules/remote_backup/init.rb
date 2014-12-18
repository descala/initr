require 'redmine'

Rails.logger.info 'Starting remote_backup plugin for Initr'

Initr::Plugin.register :remote_backup do
  name 'remote_backup'
  author 'Ingent'
  description 'RemoteBackup plugin for initr'
  version '0.0.1'
  project_module :initr do
    permission :configure_remote_backup,
      { :remote_backup => [:configure], :remote_backup_server => [:configure] },
      :require => :member
  end
  klasses 'remote_backup' => 'Configures encrypted remote backups',
          'remote_backup_server' => 'Holds backups for remote_backup klass'
end
