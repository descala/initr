# Redmine initr plugin
require 'redmine'

Rails.logger.info 'Starting base plugin for Initr'

Initr::Plugin.register :base do
  name 'base'
  author 'Ingent'
  description 'DNS server plugin for initr'
  version '0.0.1'
  project_module :initr do
    add_permission :edit_klasses, { :base => [:configure] }
  end
  klasses  'base' => 'Configures puppet and includes operating system classes'
end
