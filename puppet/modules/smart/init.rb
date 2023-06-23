# Redmine initr plugin
require 'redmine'

Rails.logger.info 'Starting smart plugin for Initr'

Initr::Plugin.register :smart do
  name 'smart'
  author 'Ingent'
  description 'Smart plugin for initr'
  version '0.0.1'
  project_module :initr do
    add_permission :edit_klasses, { :smart => [:configure] }
  end
  klasses 'smart' => 'Hard disk monitoring with smart'
end

::I18n.load_path += Dir.glob(File.join("#{File.dirname(__FILE__)}", 'config', 'locales', '*.yml'))
