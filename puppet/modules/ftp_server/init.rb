require 'redmine'

Rails.logger.info 'Starting ftp_server plugin for Initr'

Initr::Plugin.register :ftp_server do
  name 'ftp_server'
  author 'Ingent'
  description 'FtpServer plugin for initr'
  version '0.0.1'
  project_module :initr do
    add_permission :edit_klasses, { :ftp_server => [:configure] }
  end
  klasses 'ftp_server' => 'Ftp Server'
end
