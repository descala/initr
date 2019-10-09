# mysql
class common::mysql {

  if array_includes($classes,'nagios::nsca_node') {
    include common::mysql::nagios
  }

  service { $mysqld:
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    require    => Package['mysql-server']
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
