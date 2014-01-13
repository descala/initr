# Redmine initr plugin
require 'redmine'

Rails.logger.info 'Starting nagios plugin for Initr'

Initr::Plugin.register :nagios do
  redmine do
    name 'nagios'
    author 'Ingent'
    description 'Nagios management plugin for initr'
    version '0.0.1'
    project_module :initr do
      add_permission :edit_klasses,
        { :nagios => [:configure, :new_check, :create_check, :edit_check, :update_check, :before_destroy_check, :add_check],
          :nagios_server => [:configure] }
      # permission used to determine who receives nagios alerts
      permission :nagios_alerts, {}, :require => :member
    end
  end
  klasses 'nagios' => 'Nagios monitoring', 'nagios_server' => 'Nagios server'
end

::I18n.load_path += Dir.glob(File.join("#{File.dirname(__FILE__)}", 'config', 'locales', '*.yml'))
