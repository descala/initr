# Redmine initr plugin
require 'redmine'

Rails.logger.info 'Starting ssh_station plugin for Initr'

Initr::Plugin.register :ssh_station do
  name 'ssh_station'
  author 'Ingent'
  description 'SshStation plugin for initr'
  version '0.0.1'
  project_module :initr do
    add_permission :edit_klasses, { :ssh_station => [:configure, :add_port, :edit_port, :del_port, :get_user_nodes, :my_ssh_config],
      :ssh_station_server => [:configure] }
  end
  klasses 'ssh_station' => 'Ssh station client node', 'ssh_station_server' => 'Ssh station server'
end

begin
  # This plugin needs "public key" users custom field
  if UserCustomField.find_by_name("public key").nil?
    ucf = UserCustomField.new
    ucf.name="public key"
    ucf.field_format="text"
    ucf.default_value=""
    ucf.save
  end
rescue
  # redmine database has not been migrated yet
end

require File.join(File.dirname(__FILE__), 'rails_lib/initr/public_key')
