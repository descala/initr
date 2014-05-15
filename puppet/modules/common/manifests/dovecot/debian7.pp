class common::dovecot::debian7 inherits common::dovecot::debian {

  package { 'dovecot-mysql':
    ensure => installed,
  }

  Service[dovecot] {
    require => [Package['dovecot-imapd'],Package['dovecot-pop3d'],Package['dovecot-mysql']]
  }

  # prevent error on every login:
  # pam_authenticate() failed: Authentication failure (/etc/pam.d/dovecot missing?)
  file {
    '/etc/pam.d/dovecot':
      content => '',
      replace => false;
  }

}
