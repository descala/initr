class ssh_station::sshd_with_root_login inherits ssh_station::sshd {
  File["sshdconfig"] {
    source => [ "puppet:///specific/sshd_config", "puppet:///modules/ssh_station/sshd_config_with_root_login" ],
  }
}

