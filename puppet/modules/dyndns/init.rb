require 'redmine'

Rails.logger.info 'Starting dyndns plugin for Initr'

Initr::Plugin.register :dyndns do
  name 'dyndns'
  author 'Ingent'
  description 'Dyndns plugin for initr'
  version '0.0.1'
  project_module :initr do
    add_permission :edit_klasses, { :dyndns => [:configure] }
  end
  klasses 'dyndns' => 'Dyndns node'
end

