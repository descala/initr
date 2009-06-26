require 'redmine'

RAILS_DEFAULT_LOGGER.info 'Starting initr_webserver1'

Initr::Plugin.register :webserver1 do
  redmine do
    name 'webserver1'
    author 'Ingent'
    description 'Webserver management plugin'
    version '0.0.1'
    project_module :initr do
      permission :initr_webserver_configure,
        { :initr_webserver1 => [:configure, :add_domain, :edit_domain, :rm_domain] },
        :require => :member
    end
  end
  klasses 'webserver1' => 'LAMP web server. You can manage virtual hosts, ftp users and databases'
end
