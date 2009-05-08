# Redmine initr plugin
require 'redmine'

RAILS_DEFAULT_LOGGER.info 'Starting initr_webserver1 plugin for RedMine'

Redmine::Plugin.register :initr_webserver1 do
  name 'initr_webserver1'
  author 'Ingent'
  description 'Webserver management plugin for initr'
  version '0.0.1'
  permission :initr_webserver_configure,
    :initr_webserver1 => [:configure, :add_domain, :edit_domain, :rm_domain],
    :require => :member
end
