# Redmine initr plugin
require 'redmine'

Rails.logger.info 'Starting squid plugin for Initr'

Initr::Plugin.register :squid do
  name 'squid'
  author 'Ingent'
  description 'Squid plugin for initr'
  version '0.0.1'
  project_module :initr do
    add_permission :edit_klasses, { :squid => [:configure] }
  end
  klasses 'squid' => 'Squid server node'
end
