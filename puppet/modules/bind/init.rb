# Redmine initr plugin
require 'redmine'

Rails.logger.info 'Starting bind plugin for Initr'

Initr::Plugin.register :bind do
  redmine do
    name 'bind'
    author 'Ingent'
    description 'DNS server plugin for initr'
    version '0.0.1'
    project_module :initr do
      add_permission :edit_klasses, { :bind => [:configure, :add_zone, :edit_zone, :destroy_zone] }
    end
  end
  klasses 'bind' => 'DNS server'
end

::I18n.load_path += Dir.glob(File.join("#{File.dirname(__FILE__)}", 'config', 'locales', '*.yml'))
