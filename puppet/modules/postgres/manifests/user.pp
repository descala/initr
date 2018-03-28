define postgres::user($ensure, $password = false, $superuser = false) {
  $passtext = $password ? {
    false => "",
    default => "ENCRYPTED PASSWORD '$password'"
  }
  $options = $superuser ? {
    true => "CREATEDB CREATEUSER",
    default => "",
  }
  case $ensure {
    present: {
      # The createuser command always prompts for the password.
      exec { "Create $name postgres user":
        command => "/usr/bin/psql template1 -c \"CREATE USER $name $passtext $options\"",
        user => "postgres",
        unless => "/usr/bin/psql template1 -c '\\du' | grep '^  *$name'",
        require => Package[$postgres],
      }
    }
    absent:  {
      exec { "Remove $name postgres user":
        command => "/usr/bin/dropuser $name",
        user => "postgres",
        onlyif => "/usr/bin/psql template1 -c '\\du' | grep '$name  *|'",
        require => Package[$postgres],
      }
    }
    default: {
      fail "Invalid 'ensure' value '$ensure' for postgres::user"
    }
  }
}

