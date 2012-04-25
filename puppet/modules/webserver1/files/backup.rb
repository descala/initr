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
  def initialize(domain, server, port, bdays, excludes, remote_user)
    validate(ARGV)
    @excludes = excludes
    @domain  = domain
    @server  = server
    @port    = port
    @bdays   = bdays #TODO
    @bakdir="\"../" + `date +%Y-%m-%d/%H-%M-%S`.sub(/\n/,  '') + "\""
    @remote_user = remote_user.size > 0 ? remote_user : domain
  end

  def do_backup
    command =  "nice -n 19 rsync --delete -a -v --backup --backup-dir=#{@bakdir}"
    unless @excludes.nil? or @excludes.size == 0
      command += " --exclude-from=#{@excludes} --delete-excluded"        # excludes
    end
    command += " -e 'ssh -p #{@port} -i /etc/ssh/ssh_host_dsa_key'"      # ssh options
    command += " /var/www/#{@domain}/htdocs /var/www/#{@domain}/backups" # origin
    command += " #{@remote_user}@#{@server}:incremental"                      # destination
    puts "Syncronizing backup with server, command: #{command}"
    system command
    return $?.exitstatus
  end

  def self.already_running?
    return false # TODO
  end

  def self.usage
    puts "USAGE: backups.rb <domain.tld> [server] [port] [bdays] [excludes] [remote_user]"
  end

  def rsync_code(val)
    h = {  0  => "Success",
      1 => "Syntax or usage error",
      2 => "Protocol incompatibility",
      3 => "Errors selecting input/output files, dirs",
      4 => "Requested action not supported: an attempt was made to manipulate 64-bit files on a platform that  cannot  support them; or an option was specified that is supported by the client and not by the server.",
      5 => "Error starting client-server protocol",
      6 => "Daemon unable to append to log-file",
      10 => "Error in socket I/O",
      11 => "Error in file I/O",
      12 => "Error in rsync protocol data stream",
      13 => "Errors with program diagnostics",
      21 => "Some error returned by waitpid()",
      22 => "Error allocating core memory buffers",
      23 => "Partial transfer due to error",
      24 => "Partial transfer due to vanished source files",
      25 => "The --max-delete limit stopped deletions",
      30 => "Timeout in data send/receive"
    }
    "#{val} #{h[val]}"
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
  info = ""

  if ARGV.size != 6
    Backup.usage
    puts "Exiting with status 3 (UNKNOWN)"
    exit 3
  end

  begin
    cop = Backup.new(*ARGV)
    retval += cop.do_backup
    info = cop.rsync_code(retval)
  rescue Exception => e
    puts e.to_s
    puts e.backtrace
    puts "Exiting with status 3 (UNKNOWN)"
    exit 3
  end

  puts "#{info} (WARNING)" if retval != 0
  exit 1 if retval != 0

  puts "#{info} (OK)"
end
