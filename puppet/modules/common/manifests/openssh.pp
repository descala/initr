class openssh {

  package { $ssh:
    ensure => installed,
  }

  service { $ssh_service:
    ensure => running,
    enable => true,
  }

}
