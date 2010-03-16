require 'redmine'

RAILS_DEFAULT_LOGGER.info 'Starting webserver1'

Initr::Plugin.register :webserver1 do
  redmine do
    name 'webserver1'
    author 'Ingent'
    description 'Webserver management plugin'
    version '0.0.1'
    project_module :initr do
      add_permission :edit_klasses,
        { :webserver1         => [:configure, :add_domain, :edit_domain, :rm_domain],
          :web_backups_server => [:configure] }
    end
  end
  klasses 'webserver1' => 'LAMP web server. You can manage virtual hosts, ftp users and databases',
          'web_backups_server' => 'Acts as a backup server for webserver1'
end

::I18n.load_path += Dir.glob(File.join("#{File.dirname(__FILE__)}", 'config', 'locales', '*.yml'))
