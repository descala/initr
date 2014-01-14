require 'redmine'

Rails.logger.info 'Starting wpkg'

Initr::Plugin.register :wpkg do
  name 'wpkg'
  author 'Ingent'
  description 'WPKG management plugin for initr'
  version '0.0.1'
  project_module :initr do
    add_permission :edit_klasses,
      { :initr_wpkg => [ :configure ] }
  end
  klasses 'wpkg' => 'A windows package manager'
end
