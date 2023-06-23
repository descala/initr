define postgres::exec($database) {
  exec { "psql '$database' --file '$name'":
    user => "postgres",
    group => "postgres",
    refreshonly => true,
  }
}

