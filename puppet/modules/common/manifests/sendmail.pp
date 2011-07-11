class sendmail {

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

class rm_sendmail {
  package { "sendmail": ensure => absent }
  package { "sendmail-cf": ensure => absent }
  package { "sendmail-base": ensure => absent }
  package { "sendmail-bin": ensure => absent }
#  service { "sendmail": ensure => absent }
}
