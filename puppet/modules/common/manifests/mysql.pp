# mysql
class common::mysql {

  if array_includes($classes,'nagios::nsca_node') {
    include common::mysql::nagios
  }

  service { $mysqld:
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
  }

  package { [$mysqlclient, 'mysql-server']:
    ensure => 'installed',
  }

  file {
    '/root/.my.cnf':
      ensure => present,
      mode   => '0600';
  }

}
