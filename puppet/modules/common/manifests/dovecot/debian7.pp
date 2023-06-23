class common::dovecot::debian7 inherits common::dovecot::debian {

  $dovecot_sql_package = $db_backend ? {
    'postgres' => 'dovecot-pgsql',
    default    => 'dovecot-mysql'
  }

  package { $dovecot_sql_package:
    ensure => installed,
  }

  Service[dovecot] {
    require => [Package['dovecot-imapd'],Package['dovecot-pop3d'],Package[$dovecot_sql_package]]
  }

  exec {
    # see /usr/share/doc/dovecot-core/README.Debian.gz
    'addgroup --system --group dovenull ; usermod -g dovenull dovenull':
      onlyif => '/usr/bin/groups dovenull | /bin/grep -q nogroup';
  }

}
