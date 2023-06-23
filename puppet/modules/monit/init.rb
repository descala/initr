# Redmine initr plugin
require 'redmine'

Rails.logger.info 'Starting monit plugin for Initr'

Initr::Plugin.register :monit do
  name 'monit'
  author 'Ingent'
  description 'Monit plugin for initr'
  version '0.0.1'
  project_module :initr do
    add_permission :edit_klasses, { :monit => [:configure] }
  end
  klasses 'monit' => 'Monit node'
end
