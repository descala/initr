require 'redmine'

RAILS_DEFAULT_LOGGER.info 'Starting copy_klass plugin for Initr'

Initr::Plugin.register :copy_klass do
  redmine do
    name 'copy_klass'
    author 'Ingent'
    description 'CopyKlasses plugin for initr'
    version '0.0.1'
    project_module :initr do
      permission :configure_copy_klass,
        { :copy_klass => [:configure] },
        :require => :member
    end
  end
  klasses 'copy_klass' => 'copy a class from other node'
end

::I18n.load_path += Dir.glob(File.join("#{File.dirname(__FILE__)}", 'config', 'locales', '*.yml'))
