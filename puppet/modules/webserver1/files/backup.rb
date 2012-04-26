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

  attr_reader :info

  # $name $web_backups_server $port $history $excludes $awstats_www, $database
  def initialize(domain, server, port, bdays, excludes, remote_user, awstats_www, database, db_user, db_passwd)
    validate(ARGV)
    @excludes = excludes
    @domain  = domain
    @server  = server
    @port    = port
    @bdays   = bdays #TODO
    @bakdir="\"../" + `date +%Y-%m-%d/%H-%M-%S`.sub(/\n/,  '') + "\""
    @remote_user = remote_user.size > 0 ? remote_user : domain
    @awstats_www = awstats_www
    @database = database
    @db_user = db_user
    @db_passwd = db_passwd
    @info = ""
  end

  def local_backup_conf_and_cgi
    command = "nice -n 19 rsync -a /var/www/#{@domain}/conf /var/www/#{@domain}/cgi-bin /var/www/#{@domain}/backups/ &> /dev/null"
    system command
    retval = $?.exitstatus
    add_info(rsync_code(retval))
    return retval
  end

  def local_backup_awstats
    if @awstats_www == "true"
      command = "nice -n 19 rsync -a /var/lib/awstats/awstats??????.www.#{@domain}.??? /var/www/#{@domain}/backups/awstats/ &> /dev/null"
    else
      command = "nice -n 19 rsync -a /var/lib/awstats/awstats??????.#{@domain}.??? /var/www/#{@domain}/backups/awstats/ &> /dev/null"
    end
    system command
    retval = $?.exitstatus
    add_info(rsync_code(retval))
    return retval
  end

  def local_backup_database
    retval = 0
    if @database.size > 0
      sqlbak="/var/www/#{@domain}/backups/#{@domain}.sql"
      command = "(/usr/bin/mysqldump -u #{@db_user} -p#{@db_passwd} #{@database} > #{sqlbak} && gzip -f #{sqlbak} && chmod 600 #{sqlbak}.gz) &> /dev/null"
      system command
      retval = $?.exitstatus
      add_info("Error with database backup") if retval != 0
    end
    return retval
  end

  def do_backup
    command =  "nice -n 19 rsync --delete -a -v --backup --backup-dir=#{@bakdir}"
    unless @excludes.nil? or @excludes.size == 0
      command += " --exclude-from=#{@excludes} --delete-excluded"        # excludes
    end
    command += " -e 'ssh -p #{@port} -i /etc/ssh/ssh_host_dsa_key'"      # ssh options
    command += " /var/www/#{@domain}/htdocs /var/www/#{@domain}/backups" # origin
    command += " #{@remote_user}@#{@server}:incremental &> /dev/null"    # destination
    system command
    retval = $?.exitstatus
    add_info(rsync_code(retval))
    return retval
  end

  def self.already_running?
    return false # TODO
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
    if h.keys.include?(val)
      "#{val} #{h[val]}"
    else
      "#{val} (unknown return code)"
    end
  end

  def add_info(to_add)
    @info = "#{@info} - " if @info.size > 0
    @info = "#{@info}#{to_add}"
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

  if ARGV.size != 10
    puts "Exiting with status 3 (UNKNOWN)"
    exit 3
  end

  begin
    cop = Backup.new(*ARGV)
    retval += cop.local_backup_conf_and_cgi
    retval += cop.local_backup_awstats
    retval += cop.local_backup_database
    retval += cop.do_backup
    info = cop.info
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
