class mysql {

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

define mysql::database($ensure, $owner, $passwd) {

  $dbcr = "CREATE DATABASE IF NOT EXISTS $name;"
  $priv = "GRANT ALL PRIVILEGES ON $name.* TO $owner@localhost IDENTIFIED BY '$passwd';"

  case $ensure {
    present: {
      exec {
        "Create MySQL DB: $name":
          command => "mysql -e \"$dbcr\"",
          user => "root",
          unless => "/usr/bin/mysql $name -e \";\"",
          require => Service[$mysqld];
        "MySQL Privileges for $owner to DB $name":
          command => "mysql -e \"$priv\"",
          user => "root",
          unless => "/usr/bin/mysqlshow --user=$owner --password=$passwd $name",
          require => Exec["Create MySQL DB: $name"];
      }
    }
    absent: {
      exec { "Drop MySQL DB: $name":
        command => "mysql -e \"DROP DATABASE $name;\"",
        user => "root",
        onlyif => "/usr/bin/mysqlshow $name",
      }
    }
    default: {
      fail "Invalid 'ensure' value '$ensure' for mysql::database"
    }
  }
}

define mysql::database::backup($destdir, $user, $pass, $hour="3", $min="0") {
  cron { "backup $name":
    command => "/bin/sleep \$[ ( \$RANDOM \\% 600  ) ] ; /usr/bin/mysqldump -u $user -p$pass $name > $destdir/$name.sql ; gzip -f $destdir/$name.sql ; chmod 600 $destdir/$name.sql.gz",
    user => root,
    hour => $hour,
    minute => $min,
  }
}

class mysql::nagios {
  nagios::nsca_node::wrapper_check { "mysql":
    command => "$nagios_plugins_dir/check_mysql_with_passwd",
  }

  file { "$nagios_plugins_dir/check_mysql_with_passwd":
    owner => root,
    group => root,
    mode => 700,
    content => template("base/check_mysql_with_passwd.erb"),
  }

  package { $mysql_dev:
    ensure => installed,
  }
}
