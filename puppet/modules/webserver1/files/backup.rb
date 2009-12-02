#!/usr/bin/env ruby
#
# This script should exit with nagios-compatible status:
#
# 0: correct state
# 1: warning state
# 2: critical state
# 3: unknown state
#


class Backup

  # $name $web_backups_server $port $history $excludes
  def initialize(domain, server, port=22, bdays=7, excludes="")
    validate(ARGV)
    @excludes = excludes
    @domain  = domain
    @server  = server
    @port    = port
    @bdays   = bdays #TODO
    @bakdir="\"../" + `date +%Y-%m-%d/%H-%M-%S`.sub(/\n/,  '') + "\""
  end

  def do_backup
    command =  "nice -n 19 rsync --delete -a -v --backup --backup-dir=#{@bakdir}"
    unless @excludes.nil? or @excludes.size == 0
      command += " --exclude-from=#{@excludes} --delete-excluded"        # excludes
    end
    command += " -e 'ssh -p #{@port} -i /etc/ssh/ssh_host_dsa_key'"      # ssh options
    command += " /var/www/#{@domain}/htdocs /var/www/#{@domain}/backups" # origen
    command += " #{@domain}@#{@server}:incremental"                      # desti
    puts "Syncronizing backup with server, command: #{command}"
    system command
    return $?.exitstatus
  end

  def self.already_running?
    return false # TODO
  end

  def self.usage
    puts "USAGE: backups.rb <domain.tld> [server] [excludes]"
  end

  private

  def validate(args)
    if args.join =~ /[ ;|&"'<>]/
      raise "Illegal characters at command arguments"
    end
  end

end


if __FILE__ == $0

  retval = 0

  if ARGV.size < 2 or ARGV.size > 4
    Backup.usage
    puts "Exiting with status 3 (UNKNOWN)"
    exit 3
  end

  begin
    sleeptime=rand(600)
    puts "sleep(#{sleeptime})"
    sleep(sleeptime)
    cop = Backup.new(*ARGV)
    retval += cop.do_backup
  rescue Exception => e
    puts e.to_s
    puts e.backtrace
    puts "Exiting with status 3 (UNKNOWN)"
    exit 3
  end

  puts "Exiting with status 1 (WARNING)" if retval != 0
  exit 1 if retval != 0

  puts "Exiting with status 0 (OK)"
end
