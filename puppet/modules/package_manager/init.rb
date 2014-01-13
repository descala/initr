require 'redmine'

Rails.logger.info 'Starting package_manager plugin for Initr'

Initr::Plugin.register :package_manager do
  redmine do
    name 'package_manager'
    author 'Ingent'
    description 'PackageManager plugin for initr'
    version '0.0.1'
    project_module :initr do
      permission :configure_package_manager,
        { :package_manager => [:configure] },
        :require => :member
    end
  end
  klasses 'package_manager' => 'Manage updates on this node'
end

::I18n.load_path += Dir.glob(File.join("#{File.dirname(__FILE__)}", 'config', 'locales', '*.yml'))
