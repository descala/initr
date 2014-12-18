class mailserver::postgres {

  package {
    'postgresql':
      ensure => installed;
    'php5-pgsql':
      ensure => installed;
    'postfix-pgsql':
      ensure => installed,
      notify => Service['postfix'];
  }

  service {
    'postgresql':
      ensure  => running,
      require => Package['postgresql'];
  }

  mailserver::postgres::database { $::db_name:
    owner  => $::db_user,
    passwd => $::db_passwd;
  }

}
