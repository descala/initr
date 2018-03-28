# Redmine initr plugin
require 'redmine'

Rails.logger.info 'Starting initr_mailserver2'

Initr::Plugin.register :mailserver2 do
  name 'mailserver2'
  author 'Ingent'
  description 'Mailserver management plugin for initr'
  version '0.0.1'
  project_module :initr do
    add_permission :edit_klasses, { :initr_mailserver2 => [:configure] }
  end
  klasses 'mailserver2' => 'Complete mail server solution, with dovecot and postfixadmin'
end
