# Redmine initr plugin
require 'redmine'

Rails.logger.info 'Starting initr_mailserver'

Initr::Plugin.register :mailserver do
  name 'mailserver'
  author 'Ingent'
  description 'Mailserver management plugin for initr'
  version '0.0.1'
  project_module :initr do
    add_permission :edit_klasses, { :initr_mailserver => [:configure] }
  end
  klasses 'mailserver' => 'Complete mail server solution, with dovecot and postfixadmin'
end
