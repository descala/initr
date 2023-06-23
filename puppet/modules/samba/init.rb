require 'redmine'

Rails.logger.info 'Starting samba plugin for Initr'

Initr::Plugin.register :samba do
  name 'samba'
  author 'Ingent'
  description 'Samba plugin for initr'
  version '0.0.1'
  project_module :initr do
    permission :configure_samba,
      { :samba => [:configure] },
      :require => :member
  end
  klasses 'samba' => 'Samba server'
end

::I18n.load_path += Dir.glob(File.join("#{File.dirname(__FILE__)}", 'config', 'locales', '*.yml'))
