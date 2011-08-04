class common::sendmail {

  file { "/etc/alternatives/mta":
    ensure => "/usr/sbin/sendmail.sendmail",
  }

  package { "sendmail":
    ensure => installed,
    require => Package[$exim],
  }

  service { "sendmail":
    enable => true,
    ensure => running,
    hasrestart => true,
    hasstatus => true,
    require => Package["sendmail"],
  }

  package { $exim:
    ensure => absent,
  }

}

