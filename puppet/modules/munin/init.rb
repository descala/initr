# Redmine initr plugin
require 'redmine'

Rails.logger.info 'Starting munin plugin for Initr'

Initr::Plugin.register :munin do
  name 'munin'
  author 'Ingent'
  description 'Munin graphics plugin for initr'
  version '0.0.1'
  project_module :initr do
    add_permission :view_nodes,     { :munin => [:index,:graphs] }
    add_permission :view_own_nodes, { :munin => [:index,:graphs] }
    add_permission :edit_klasses,   { :munin => [:configure],
      :munin_server => [:configure] }
  end
  klasses 'munin' => 'Munin node', 'munin_server' => 'Munin server'
end

::I18n.load_path += Dir.glob(File.join("#{File.dirname(__FILE__)}", 'config', 'locales', '*.yml'))
