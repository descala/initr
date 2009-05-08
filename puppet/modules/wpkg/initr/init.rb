# Redmine initr plugin
require 'redmine'

RAILS_DEFAULT_LOGGER.info 'Starting wpkg plugin for Initr'

Redmine::Plugin.register :wpkg do
  name 'wpkg'
  author 'Ingent'
  description 'WPKG management plugin for initr'
  version '0.0.1'
  permission :wpkg_configure,
    :initr_wpkg => [ :configure ],
    :require => :member
end
