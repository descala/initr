require 'redmine'

Rails.logger.info 'Starting initr plugin for Redmine'

require 'initr/plugin'
require 'initr/klass_definition'
require 'puppet_report_patch'
require 'access_control_patch'

require 'puppet_patch'
require 'issue_status_patch'
require 'project_patch'
require 'tracker_patch'
require 'user_patch'
require 'redmine_plugin_patch'

Rails.configuration.to_prepare do
  Project.send(:include, ProjectInitrPatch)
  User.send(:include, UserInitrPatch)
  [
    Puppet::Rails::Host,
    Puppet::Rails::FactName,
    Puppet::Rails::FactValue,
    Puppet::Rails::Resource,
    Puppet::Rails::ParamValue,
    Puppet::Rails::ParamName,
    Puppet::Rails::ResourceTag,
    Puppet::Rails::PuppetTag,
    Puppet::Rails::SourceFile
  ].each do |c|
    c.send(:include, PuppetPatch)
  end
  Puppet::Transaction::Report.send(:include, PuppetReportPatch)
  Tracker.send(:include, TrackerPatch)
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
      {:node  => [:list,:facts,:report,:resource],
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
#end

