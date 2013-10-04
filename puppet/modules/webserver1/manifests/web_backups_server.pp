class webserver1::web_backups_server {

  include common::sshkeys

  Ssh_authorized_key <<| tag == "${address}_web_backups_client" |>>
  File <<| tag == "${address}_web_backups_client" |>>

  file {
    ["$backups_path","$backups_path/webservers"]:
      ensure => directory;
  }

  # Defaults to 7 days of backup history
  cron { "Purge webserver backups":
    command => "find $backups_path/webservers/* -maxdepth 1 -name \"[0-9][0-9]*-[0-9][0-9]*-[0-9][0-9]*\" -ctime +7 -exec rm -rf {} \\;",
    user => root,
    hour => 2,
    minute => 30,
  }

  # there is also rssh, but unfortunately it only works on debian backup servers
  # only debian applies a patch which allows rsync's -e option

  # TODO: this does not work on ruby 1.9 so we have set rssh shellfor all users:
  # http://projects.puppetlabs.com/issues/15575

  #case $operatingsystem {
  #    "Debian": {
  #      include common::rssh
  #       User <<| tag == "${address}_web_backups_client" |>> {
  #         shell => "/usr/bin/rssh"
  #       }
  #    }
  #    default: {
  #       User <<| tag == "${address}_web_backups_client" |>>
  #    }
  #  }
  include common::rssh
  User <<| tag == "${address}_web_backups_client" |>>

}

