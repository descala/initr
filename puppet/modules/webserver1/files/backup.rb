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

  RSYNC="/usr/bin/rsync"
  NICE="/bin/nice"

  def initialize(domain, server, port=22, history=7, excludes="")
    validate(ARGV)
    @excludes = excludes
    @history = history
    @domain  = domain
    @server  = server
    @port    = port
    @bakdir="\"../" + `date +%Y-%m-%d/%H-%M-%S`.sub(/\n/,  '') + "\""
  end

  def do_backup
    command =  "#{NICE} -n 19 #{RSYNC} --delete -a -v --backup --backup-dir=#{@bakdir}"
    unless @excludes.nil? or @excludes.size == 0
      command += " --exclude-from=#{@excludes} --delete-excluded"                         # excludes
    end
    command += " -e 'ssh -p #{@port} -i /etc/ssh/ssh_host_dsa_key'"                        # ssh options
    command += " /var/www/#{@domain}/htdocs /var/www/#{@domain}/backups"                  # origen
    command += " #{@domain}@#{@server}:/var/backups/webservers/#{@domain}/incremental"    # desti
    puts "Syncronizing backup with server, command: #{command}"
    system command
    return $?.exitstatus
  end

  def purge_history
    command =  "ssh -p #{@port} #{@domain}@#{@server} -i /etc/ssh/ssh_host_dsa_key" 
    command += " find /var/backups/webservers/#{@domain} -maxdepth 1"
    command += " -name \"[0-9][0-9]*-[0-9][0-9]*-[0-9][0-9]*\""
    command += " -ctime +#{@history}"
    command += " -exec \"rm -rf '{}' \\;\""
    puts "Deleting old historic files, command: #{command}"
    system command
    return $?.exitstatus
  end

  def self.already_running?
    return false # TODO
  end

  def self.usage
    puts "USAGE: backups.rb <domain.tld> [server] [history days] [excludes]"
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
    puts "sleep(#{rand(600)})"
    sleep(rand(600))
    cop = Backup.new(*ARGV)
    retval += cop.do_backup
    retval += cop.purge_history if retval == 0
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
