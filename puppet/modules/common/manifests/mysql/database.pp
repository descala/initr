define common::mysql::database($ensure, $owner, $passwd) {

  $dbcr = "CREATE DATABASE IF NOT EXISTS ${name};"
  $priv = "GRANT ALL PRIVILEGES ON ${name}.* TO '${owner}'@localhost IDENTIFIED BY '${passwd}';"

  if $::operatingsystem == 'Debian' and $::lsbmajdistrelease in ['8','9'] {
    $cmd='/usr/bin/mysql'
    $cmd_show='/usr/bin/mysqlshow'
  } else {
    $cmd='/usr/bin/mysql'
    $cmd_show='/usr/bin/mysqlshow'
  }

  case $ensure {
    present: {
      exec {
        "Create MySQL DB: ${name}":
          command => "${cmd} -e \"${dbcr}\"",
          user    => root,
          unless  => "${cmd} ${name} -e \";\"",
          require => Service[$::mysqld];
        "MySQL Privileges for ${owner} to DB ${name}":
          command => "${cmd} -e \"${priv}\"",
          user    => root,
          unless  => "${cmd_show} --user=${owner} --password=${passwd} ${name}",
          require => Exec["Create MySQL DB: ${name}"];
      }
    }
    absent: {
      exec { "Drop MySQL DB: ${name}":
        command => "${cmd} -e \"DROP DATABASE ${name};\"",
        user    => root,
        onlyif  => "${cmd_show} ${name}",
      }
    }
    default: {
      fail "Invalid 'ensure' value '${ensure}' for mysql::database"
    }
  }
}

