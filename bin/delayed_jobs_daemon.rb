#!/usr/bin/env ruby

require "rubygems"
require "daemons"
require "yaml"
settings = YAML.load `cat #{File.expand_path(File.dirname(__FILE__))}/../server_info.yml`

def running?(pid)
  # Check if process is in existence
  # The simplest way to do this is to send signal '0'
  # (which is a single system call) that doesn't actually
  # send a signal
  begin
    Process.kill(0, pid)
    return true
  rescue Errno::ESRCH
    return false
  rescue ::Exception   # for example on EPERM (process exists but does not belong to us)
    return true
  end
end

if ARGV.size == 1 and ARGV.first == "status"
  pidfile = "#{settings["RAILS_ROOT"]}/tmp/pids/delayed_jobs_worker.rb.pid"
  puts pidfile
  if File.exists?(pidfile)
    pid = open(pidfile).readlines.first.strip.to_i
    if running?(pid)
      puts "delayed_job_worker is running (#{pid})"
    else
      puts "delayed_job_worker is NOT running (#{pid})"
    end
  else
    puts "delayed_job_worker is NOT running (none)"
  end
else
  Daemons.run(File.dirname(__FILE__) + '/delayed_jobs_worker.rb',
              :backtrace => true,
              :log_output => true,
              :dir => "#{settings["RAILS_ROOT"]}/tmp/pids",
              :dir_mode => :normal,
              :multiple => false)
end

