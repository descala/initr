require File.expand_path('../../../../test/test_helper', __FILE__)

module Initr
  module TestHelper

    def self.initr_setup

      # Plugin config
      Setting.plugin_initr = {'puppetmaster'=>'puppet', 'puppetmaster_ip'=>'127.0.0.1','puppetmaster_port'=>'8140'}

      modules = [:initr, :base, :bind, :common, :custom_klasses, :fail2ban, :link_klass, :nagios, :package_manager, :remote_backup, :webserver1, :wpkg]

      # Enables modules on project 'OnlineStore'
      modules.each do |m|
        Project.find(2).enabled_modules << EnabledModule.new(:name => m)
      end

      permissions = [:add_nodes,:add_templates,:view_nodes,:view_own_nodes,:edit_nodes,:edit_own_nodes,:delete_nodes,:delete_own_nodes,:edit_klasses, :edit_klasses_of_own_nodes]

      # Adds all permissions to role 'delveloper'
      dev = Role.find(2)
      dev.permissions += permissions
      dev.save

      # user 2 (jsmith) is member of project 2 (onlinesotre) with role 2 (developer)

    end

  end
end

Initr::TestHelper.initr_setup

class ActiveSupport::TestCase
  self.fixture_path = File.dirname(__FILE__) + '/fixtures'
#  self.use_transactional_fixtures = true
#  self.use_instantiated_fixtures  = true
end

class ActionDispatch::IntegrationTest
  self.fixture_path = File.dirname(__FILE__) + '/fixtures'
#  self.use_transactional_fixtures = true
#  self.use_instantiated_fixtures  = true
end
