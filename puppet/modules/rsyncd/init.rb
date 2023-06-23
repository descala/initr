require 'redmine'

Rails.logger.info 'Starting rsyncd plugin for Initr'

Initr::Plugin.register :rsyncd do
  name 'rsyncd'
  author 'Ingent'
  description 'Rsyncd plugin for initr'
  version '0.0.1'
  project_module :initr do
    permission :configure_rsyncd,
      { :rsyncd => [:configure] },
      :require => :member
  end
  klasses 'rsyncd' => 'Rsync server'
end

::I18n.load_path += Dir.glob(File.join("#{File.dirname(__FILE__)}", 'config', 'locales', '*.yml'))
