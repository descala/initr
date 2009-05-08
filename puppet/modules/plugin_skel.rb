#!/bin/env ruby

plugindir=File.dirname(__FILE__) + "/" + ARGV[0] if ARGV.size > 0
if ARGV.size != 1
  puts "usage: ruby plugin_skel.rb plugin_name"
elsif File.exist?(plugindir)
  puts "plugin #{ARGV[0]} already exists"
elsif !(ARGV[0] =~ /^initr_/)
  puts "plugin name must start with initr_"
else
  plugin=ARGV[0]

  `mkdir -p #{plugindir}/app/controllers`
  `touch    #{plugindir}/app/controllers/#{plugin}_controller.rb`
  `mkdir -p #{plugindir}/app/views/#{plugin}`
  `touch    #{plugindir}/app/views/#{plugin}/configure.html.erb`
  `mkdir    #{plugindir}/app/models`
  `touch    #{plugindir}/app/models/#{plugin}.rb`
  `mkdir -p #{plugindir}/db/migrate`
  `touch    #{plugindir}/README`
  `touch    #{plugindir}/init.rb`

  # TODO: write model and controller templates

end

