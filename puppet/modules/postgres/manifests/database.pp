define postgres::database($ensure, $owner = false) {
  $ownerstring = $owner ? {
    false => "",
    default => "-O $owner"
  }

  case $ensure {
    present: {
      exec { "Create $name postgres db":
        command => "/usr/bin/createdb $ownerstring $name",
        user => "postgres",
        unless => "/usr/bin/psql template1 -l | grep '$name  *|'"
      }
    }
    absent:  {
      exec { "Remove $name postgres db":
        command => "/usr/bin/drop $name",
        onlyif => "/usr/bin/psql template1 -l | grep '$name  *|'",
        user => "postgres"
      }
    }
    default: {
      fail "Invalid 'ensure' value '$ensure' for postgres::database"
    }
  }
}

