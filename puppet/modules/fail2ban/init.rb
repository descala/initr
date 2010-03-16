# Redmine initr plugin
require 'redmine'

RAILS_DEFAULT_LOGGER.info 'Starting fail2ban plugin for Initr'

Initr::Plugin.register :fail2ban do
  redmine do
    name 'fail2ban'
    author 'Ingent'
    description 'Fail2ban plugin for initr'
    version '0.0.1'
    # create a redmine project module
    project_module :initr do
      # add a permission so not everybody can configure fail2ban
      # see http://www.redmine.org/wiki/redmine/Plugin_Tutorial
      # and http://www.redmine.org/issues/5095
      add_permission :edit_klasses, { :fail2ban => [:configure] }
    end
  end
  # This plugin adds a puppet module called fail2ban
  klasses 'fail2ban' => 'Fail2ban node'
end
