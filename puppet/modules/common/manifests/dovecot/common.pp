class common::dovecot::common {

  service { "dovecot":
    enable => true,
    ensure => running,
    hasrestart => true,
    hasstatus => true,
  }

}

