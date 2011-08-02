class common::mysql {

  if array_includes($classes,"nagios::nsca_node") {
    include mysql::nagios
  }

  service { $mysqld:
    ensure => "running",
    enable => true,
    hasrestart => true,
  }

  package { [$mysqlclient, "mysql-server"]:
    ensure => "installed",
  }

  file {
    "/root/.my.cnf":
      mode => 600;
  }

}

