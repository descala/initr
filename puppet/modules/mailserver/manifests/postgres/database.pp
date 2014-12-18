define mailserver::postgres::database($owner, $passwd) {

  exec {
    "Create PostgreSQL USER: ${owner}":
      command => "psql -c \"CREATE USER ${owner} WITH PASSWORD '${passwd}';\"",
      user    => 'postgres',
      unless  => "psql postgres -tAc \"SELECT 1 FROM pg_roles WHERE rolname='${owner}'\" | grep 1";
    "Create PostgreSQL DB: ${name}":
      command => "createdb -O ${owner} ${name}",
      user    => 'postgres',
      unless  => "psql -lqt | cut -d \| -f 1 | grep -w ${name}";
  }

}
