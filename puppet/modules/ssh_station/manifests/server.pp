class ssh_station::server {

  include common::sshkeys
  include common::openssh
  include ssh_station::server_user

  file {
    # see bug http://projects.reductivelabs.com/issues/2014
    "/etc/ssh/ssh_known_hosts":
      mode => '0644',
      content => "",
      replace => false;
    # clean removed operators files
    "/home/ssh_station_operators/":
      source => "puppet:///modules/ssh_station/empty",
      recurse => true,
      purge => true,
      notify => Exec["/usr/local/sbin/clean_initr_operators.sh"],
      backup => false,
      force => true,
      ignore => [".gitignore","master-ssh_station@localhost:*"];
    # clean removed operators users
    "/usr/local/sbin/clean_initr_operators.sh":
      mode => '0700', owner => root, group => root,
      source => "puppet:///modules/ssh_station/clean_initr_operators.sh";
  }

  exec {
    "/usr/local/sbin/clean_initr_operators.sh":
      user => root,
      require => File["/usr/local/sbin/clean_initr_operators.sh"],
      refreshonly => true;
  }

  # delete old unused control sockets, can be there if connections close badly
  # those files produce an ugly warning to the user. (ssh_config ControlPath option)
  cron {
    rm_old_sockets:
      command => "find /home/ssh_station_operators/ -name 'master-ssh_station@localhost*' -mtime +2 -delete",
      user => root,
      hour => 4,
      minute => 47;
  }

  # collect all clients rsa key to /etc/ssh/ssh_known_hosts
  Sshkey <<| tag == "ssh_station_clients_for_$fqdn" |>>

  create_resources(ssh_station::server::operator_user, $operators)
}
