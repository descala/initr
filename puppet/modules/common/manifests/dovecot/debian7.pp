class common::dovecot::debian7 inherits common::dovecot::debian {

  package { "dovecot-mysql":
    ensure => installed,
  }

  Service[dovecot] {
    require => [Package["dovecot-imapd"],Package["dovecot-pop3d"],Package["dovecot-mysql"]]
  }

}
