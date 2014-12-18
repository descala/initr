class mailserver::roundcube {

  # TODO: can we access var from mailserver::common?
  if $::db_backend == 'postgres' {
    $db_driver = 'pgsql'
  } else {
    $db_driver = 'mysql'
  }

  package {
    ['roundcube','roundcube-plugins',"roundcube-${db_driver}"]:
      ensure => installed;
  }
}
