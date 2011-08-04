define common::mysql::database($ensure, $owner, $passwd) {

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

