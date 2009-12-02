class mysql {

  #TODO: better way to know if node includes Nagios class?
  if $nagios_proxytunnel == "0" or $nagios_proxytunnel == "1" {
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
  
}

define mysql::database($ensure, $owner, $passwd) {

  $dbcr = "CREATE DATABASE IF NOT EXISTS $name;"
  $priv = "GRANT ALL PRIVILEGES ON $name.* TO $owner@localhost IDENTIFIED BY '$passwd';"

  #TODO: acces al mysql com a root amb passwd - http://redmine.ingent.net/issues/show/168
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
    command => "/usr/local/nagios/libexec/check_mysql_with_passwd",
  }

  file { "/usr/local/nagios/libexec/check_mysql_with_passwd":
    owner => root,
    group => root,
    mode => 700,
    source => "puppet:///base/check_mysql_with_passwd",
  }

  package { $mysql_dev:
    ensure => installed,
  }
}
