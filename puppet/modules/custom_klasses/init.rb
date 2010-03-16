require 'redmine'

RAILS_DEFAULT_LOGGER.info 'Starting initr plugin: custom_klasses'


Initr::Plugin.register :custom_klasses do

  redmine do
    name 'custom_klasses'
    author 'Ingent'
    description 'Manage klasses without controller'
    version '0.0.1'
    project_module :initr do
      add_permission :edit_klasses, { :custom_klass => [:new, :create, :configure] }
    end
  end
  klasses  'custom_klass' => { :description => 'Klass without controller', :unique => false }

end
