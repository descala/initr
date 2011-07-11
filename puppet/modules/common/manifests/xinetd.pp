class xinetd {

  package { xinetd:
    ensure => installed,
  }

  service { xinetd:
    ensure => running,
    enable => true,
    require => Package["xinetd"],
  }

}
