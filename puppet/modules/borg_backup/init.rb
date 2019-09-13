require 'redmine'

Rails.logger.info 'Starting borg_backup plugin for Initr'

Initr::Plugin.register :borg_backup do
  name 'borg_backup'
  author 'Ingent'
  description 'BorgBackup plugin for initr'
  version '0.0.1'
  project_module :initr do
    permission :configure_borg_backup,
      { :borg_backup => [:configure] },
      :require => :member
  end
  klasses 'borg_backup' => 'BorgBackup node'
end
