class ssh_station::sshd3 inherits ssh_station::sshd {
  File["sshdconfig"] {
    source => "puppet:///modules/ssh_station/sshd_config_v3",
  }
}
