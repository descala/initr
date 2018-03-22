class ssh_station::sshd {

  include common::openssh

  file { "sshdconfig":
    name => "/etc/ssh/sshd_config",
    mode => '0600',
    owner => root,
    group => root,
    source => [ "puppet:///specific/sshd_config", "puppet:///modules/ssh_station/sshd_config" ],
    notify => Service[$ssh_service],
  }

}

