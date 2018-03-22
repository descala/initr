class ssh_station::sshd_localhost_only inherits ssh_station::sshd {
  File["sshdconfig"] {
    source => [ "puppet:///specific/sshd_config", "puppet:///modules/ssh_station/sshd_config_localhost_only" ],
  }
}

