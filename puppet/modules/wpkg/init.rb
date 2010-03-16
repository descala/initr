require 'redmine'

RAILS_DEFAULT_LOGGER.info 'Starting wpkg'

Initr::Plugin.register :wpkg do
  redmine do
    name 'wpkg'
    author 'Ingent'
    description 'WPKG management plugin for initr'
    version '0.0.1'
    project_module :initr do
      add_permission :edit_klasses,
        { :initr_wpkg => [ :configure ] }
    end
  end
  klasses 'wpkg' => 'A windows package manager'
end
