# Redmine initr plugin
require 'redmine'

RAILS_DEFAULT_LOGGER.info 'Starting fail2ban plugin for Initr'

Initr::Plugin.register :fail2ban do
  redmine do
    name 'fail2ban'
    author 'Ingent'
    description 'Fail2ban plugin for initr'
    version '0.0.1'
    project_module :initr do
      permission :configure_fail2ban,
        { :fail2ban => [:configure] },
        :require => :member
    end
  end
  klasses 'fail2ban' => 'Fail2ban node'
end