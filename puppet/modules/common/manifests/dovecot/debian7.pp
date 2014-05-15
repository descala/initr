class common::dovecot::debian7 inherits common::dovecot::debian {

  package { 'dovecot-mysql':
    ensure => installed,
  }

  Service[dovecot] {
    require => [Package['dovecot-imapd'],Package['dovecot-pop3d'],Package['dovecot-mysql']]
  }

  exec {
    # see /usr/share/doc/dovecot-core/README.Debian.gz
    'addgroup --system --group dovenull ; usermod -g dovenull dovenull':
      onlyif => '/usr/bin/groups dovenull | /bin/grep -q nogroup';
  }

}
