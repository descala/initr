require 'redmine'
require 'byebug'

Rails.logger.info 'Starting initr plugin for Redmine'

require File.expand_path('plugins/initr/lib/initr')
require File.expand_path('plugins/initr/lib/initr/plugin')
require File.expand_path('plugins/initr/lib/initr/klass_definition')
require File.expand_path('plugins/initr/lib/redmine')

require File.expand_path('plugins/initr/lib/project_initr_patch')
require File.expand_path('plugins/initr/lib/user_initr_patch')
require File.expand_path('plugins/initr/lib/redmine_plugin_patch')

# puppet

require File.expand_path('plugins/initr/puppet/modules/base/app/models/initr/base')
require File.expand_path('plugins/initr/puppet/modules/bind/app/models/initr/bind')
require File.expand_path('plugins/initr/puppet/modules/bind/app/models/initr/bind_zone')
require File.expand_path('plugins/initr/puppet/modules/borg_backup/app/models/initr/borg_backup')
require File.expand_path('plugins/initr/puppet/modules/copier/app/models/initr/copier')
  require File.expand_path('plugins/initr/puppet/modules/copier/app/models/initr/copy')
require File.expand_path('plugins/initr/puppet/modules/custom_klasses/app/models/initr/custom_klass')
  require File.expand_path('plugins/initr/puppet/modules/custom_klasses/app/models/initr/custom_klass_conf')
require File.expand_path('plugins/initr/puppet/modules/dyndns/app/models/initr/dyndns')
require File.expand_path('plugins/initr/puppet/modules/fail2ban/app/models/initr/fail2ban')
require File.expand_path('plugins/initr/puppet/modules/ftp_server/app/models/initr/ftp_server')
  require File.expand_path('plugins/initr/puppet/modules/ftp_server/app/models/initr/ftp_user')
require File.expand_path('plugins/initr/puppet/modules/link_klass/app/models/initr/link_klass')
require File.expand_path('plugins/initr/puppet/modules/mailserver/app/models/initr_mailserver')
require File.expand_path('plugins/initr/puppet/modules/monit/app/models/initr/monit')
require File.expand_path('plugins/initr/puppet/modules/munin/app/models/initr/munin')
  require File.expand_path('plugins/initr/puppet/modules/munin/app/models/initr/munin_server')
require File.expand_path('plugins/initr/puppet/modules/nagios/app/models/initr/nagios')
  require File.expand_path('plugins/initr/puppet/modules/nagios/app/models/initr/nagios_check')
  require File.expand_path('plugins/initr/puppet/modules/nagios/app/models/initr/nagios_server')
require File.expand_path('plugins/initr/puppet/modules/package_manager/app/models/initr/package_manager')
require File.expand_path('plugins/initr/puppet/modules/rsyncd/app/models/initr/rsyncd')
require File.expand_path('plugins/initr/puppet/modules/samba/app/models/initr/samba')
require File.expand_path('plugins/initr/puppet/modules/smart/app/models/initr/smart')
require File.expand_path('plugins/initr/puppet/modules/squid/app/models/initr/squid')
require File.expand_path('plugins/initr/puppet/modules/ssh_station/app/models/initr/ssh_station')
  require File.expand_path('plugins/initr/puppet/modules/ssh_station/app/models/initr/ssh_station_port')
  require File.expand_path('plugins/initr/puppet/modules/ssh_station/app/models/initr/ssh_station_server')
require File.expand_path('plugins/initr/puppet/modules/webserver1/app/models/initr/webserver1')
  require File.expand_path('plugins/initr/puppet/modules/webserver1/app/models/initr/web_backups_server')
  require File.expand_path('plugins/initr/puppet/modules/webserver1/app/models/initr/webserver1_domain')

require File.expand_path('plugins/initr/puppet/modules/munin/app/controllers/munin_controller')
require File.expand_path('plugins/initr/puppet/modules/ssh_station/app/controllers/ssh_station_controller')



# loader = Zeitwerk::Loader.new
# loader.push_dir('plugins/initr/puppet/modules')
# loader.setup # ready!



Rails.configuration.after_initialize do
  Project.send(:include, ProjectInitrPatch)
  User.send(:include, UserInitrPatch)
  Redmine::Plugin.send(:include,RedminePluginPatch)
end

Redmine::Plugin.register :initr do
  name 'initr'
  author 'Ingent'
  description 'A fronted for puppet modules'
  version '0.1'
  settings :default => {
    'puppetmaster'      => 'puppet',
    'puppetmaster_ip'   => '127.0.0.1',
    'puppetmaster_port' => '8140'
  },
    :partial => '/initr/settings'

  # This plugin adds a project module
  # It can be enabled/disabled at project level (Project settings -> Modules)
  project_module :initr do
    permission :add_nodes,
      {:node => [:new,:scan_puppet_hosts]},
      :require => :member
    permission :add_templates,
      {:node => [:new_template]},
      :require => :loggedin
    permission :view_nodes,
      {:node  => [:list,:facts,:report,:resource,:get_services],
        :klass => [:list]}
    permission :view_own_nodes,
      {:node  => [:list,:facts,:report,:resource],
        :klass => [:list]},
        :require => :loggedin
    permission :edit_nodes,
      {:node  => [:destroy_exported_resources],
        :klass => [:create, :move, :destroy, :apply_template,:activate]},
        :require => :member
    permission :edit_own_nodes,
      {:node  => [:destroy_exported_resources],
        :klass => [:create, :move, :destroy, :apply_template,:activate]},
        :require => :loggedin
    permission :delete_nodes,
      {:node => [:destroy]},
      :require => :member
    permission :delete_own_nodes,
      {:node => [:destroy]},
      :require => :loggedin
    permission :edit_klasses,
      {:klass => [:configure]},
      :require => :member
    permission :edit_klasses_of_own_nodes,
      {},
      :require => :loggedin
  end

  # A new item is added to the project menu
  menu :project_menu, :initr, { :controller => 'node', :action => 'list' }, :caption => 'Initr'
  # A new item is added to the aplication menu
  menu :application_menu, :initr, { :controller => 'node', :action => 'list' }, :caption => 'Initr'

end

# # Load initr plugins when all is initialized
#RedmineApp::Application.config.after_initialize do

  Initr::Plugin.load
#  puts ActiveSupport::Dependencies.autoload_paths

  # dump to a file some server info need by scripts (see initr_login)
  # must be done after_initialize to avoid accessing Setting[] before all
  # plugins are loaded, which produces missing settings
  open("#{Rails.root}/plugins/initr/server_info.yml",'w') do |f|
    f.puts "# Autogenerated from initr/init.rb"
    f.puts "# Changes will be lost"
    f.puts "Rails.root: #{Rails.root}"
    f.puts "Rails.env: #{Rails.env}"
    begin
      f.puts "DOMAIN: #{Setting[:protocol]}://#{Setting[:host_name]}"
    rescue
      # redmine has no settings table yet
      f.puts "DOMAIN: http://localhost:3000"
    end
  end

# Deprecated Klasses
# ActiveRecord::Base.connection.execute("delete from klasses where type='InitrWpkg';")
# ActiveRecord::Base.connection.execute("delete from klasses where type='Initr::RemoteBackup';")
# ActiveRecord::Base.connection.execute("delete from klasses where type='Initr::RemoteBackupServer';")

#end
