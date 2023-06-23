class common::openssh {

  package { $ssh_package:
    ensure => installed,
  }

  service { $ssh_service:
    ensure => running,
    enable => true,
  }

}
