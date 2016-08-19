define common::mysql::database($ensure, $owner, $passwd) {

  $dbcr = "CREATE DATABASE IF NOT EXISTS ${name};"
  $priv = "GRANT ALL PRIVILEGES ON ${name}.* TO '${owner}'@localhost IDENTIFIED BY '${passwd}';"

  if $::operatingsystem == 'Debian' and $::lsbmajdistrelease == '8' {
    $cmd='mysql --defaults-file=/root/.my.cnf'
  } else {
    $cmd='mysql'
  }

  case $ensure {
    present: {
      exec {
        "Create MySQL DB: ${name}":
          command => "${cmd} -e \"${dbcr}\"",
          user    => root,
          unless  => "/usr/bin/mysql ${name} -e \";\"",
          require => Service[$::mysqld];
        "MySQL Privileges for ${owner} to DB ${name}":
          command => "${cmd} -e \"${priv}\"",
          user    => root,
          unless  => "/usr/bin/mysqlshow --user=${owner} --password=${passwd} ${name}",
          require => Exec["Create MySQL DB: ${name}"];
      }
    }
    absent: {
      exec { "Drop MySQL DB: ${name}":
        command => "${cmd} -e \"DROP DATABASE ${name};\"",
        user    => root,
        onlyif  => "/usr/bin/mysqlshow ${name}",
      }
    }
    default: {
      fail "Invalid 'ensure' value '${ensure}' for mysql::database"
    }
  }
}

