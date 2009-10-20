#!/bin/env ruby

plugindir=File.dirname(__FILE__) + "/" + ARGV[0] if ARGV.size > 0
if ARGV.size != 1
  puts "usage: ruby plugin_skel.rb plugin_name"
elsif File.exist?(plugindir)
  puts "plugin #{ARGV[0]} already exists"
else
  plugin=ARGV[0]

  `mkdir -p #{plugindir}/app/controllers`
  `touch    #{plugindir}/app/controllers/#{plugin}_controller.rb`
  `mkdir -p #{plugindir}/app/views/#{plugin}`
  `touch    #{plugindir}/app/views/#{plugin}/configure.html.erb`
  `mkdir -p #{plugindir}/app/models/initr`
  `touch    #{plugindir}/app/models/initr/#{plugin}.rb`
  `mkdir -p #{plugindir}/db/migrate`
  `touch    #{plugindir}/README`
  `mkdir    #{plugindir}/files`
  `mkdir    #{plugindir}/manifests`
  `mkdir    #{plugindir}/templates`
  `touch    #{plugindir}/manifests/init.pp`

  # TODO: write model and controller templates

initrb="# Redmine initr plugin
require 'redmine'

RAILS_DEFAULT_LOGGER.info 'Starting #{plugin} plugin for Initr'

Initr::Plugin.register :#{plugin} do
  redmine do
    name '#{plugin}'
    author 'Ingent'
    description '#{plugin.capitalize} plugin for initr'
    version '0.0.1'
    project_module :initr do
      permission :configure_#{plugin},
        { :#{plugin} => [:configure] },
        :require => :member
    end
  end
  klasses '#{plugin}' => '#{plugin.capitalize} node'
end"

  open("#{plugindir}/init.rb",'w') {|f| f << initrb }

end

