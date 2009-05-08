#!/usr/bin/env ruby

#unless ARGV.size == 1
#  $stderr.puts "USAGE: #{0} [environment]"
#  exit 1
#end

require "yaml"
settings = YAML.load `cat #{File.expand_path(File.dirname(__FILE__))}/../server_info.yml`

RAILS_ENV = settings["RAILS_ENV"]
require "#{settings["RAILS_ROOT"]}/config/environment.rb"

Delayed::Worker.new.start

