require 'redmine'

Rails.logger.info 'Starting copier plugin for Initr'

Initr::Plugin.register :copier do
  name 'copier'
  author 'Ingent'
  description 'Copier plugin for initr'
  version '0.0.1'
  project_module :initr do
    permission :configure_copier,
      { :copier => [:configure] },
      :require => :member
  end
  klasses 'copier' => 'Copier node'
end

::I18n.load_path += Dir.glob(File.join("#{File.dirname(__FILE__)}", 'config', 'locales', '*.yml'))
