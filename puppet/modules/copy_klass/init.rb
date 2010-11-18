require 'redmine'

require File.join(File.dirname(__FILE__), 'rails_lib','klass_patch')

Dispatcher.to_prepare do
  Initr::Klass.send(:include,KlassPatch)
end

RAILS_DEFAULT_LOGGER.info 'Starting copy_klass plugin for Initr'

Initr::Plugin.register :copy_klass do
  redmine do
    name 'copy_klass'
    author 'Ingent'
    description 'CopyKlasses plugin for initr'
    version '0.0.1'
    project_module :initr do
      add_permission :edit_klasses, { :copy_klass => [:configure] }
    end
  end
  klasses 'copy_klass' => {:description => 'copy a class from other node', :unique => false}
end

::I18n.load_path += Dir.glob(File.join("#{File.dirname(__FILE__)}", 'config', 'locales', '*.yml'))
