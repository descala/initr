class postgres {

  $pg_hba = $operatingsystem ? {
    "Debian" => $lsbmajdistrelease ? {
      "5" => "/etc/postgresql/8.3/main/pg_hba.conf",
      "6" => "/etc/postgresql/8.4/main/pg_hba.conf",
      default => "/etc/postgresql/9.1/main/pg_hba.conf"
    },
    "Ubuntu" => $lsbmajdistrelease ? {
      "11" => "/etc/postgresql/9.1/main/pg_hba.conf",
      default => "/etc/postgresql/8.4/main/pg_hba.conf"
    },
    "Gentoo" => "/home/elf/data/db/pg_hba.conf", #TODO: posar el generic de gentoo, aquest es nomes per ricoh
    default => "/var/lib/pgsql/data/pg_hba.conf"
  }
  $pg_hba_source = $operatingsystem ? {
    "Debian" => $lsbmajdistrelease ? {
      "5" => "pg_hba.conf.8.3",
      default => "pg_hba.conf"
    },
    default => "pg_hba.conf"
  }

  package { $postgres:
    ensure => installed,
  }

  service { $postgres_service:
    ensure => "running",
    enable => true,
    hasrestart => true,
    hasstatus => true,
    require => Package[$postgres],
  }

  # TODO: dona problemes, es crea el fitxer i llavors no fa initdb pq el direcori data no es buit
  # esborrar pg_hba.conf, fer initdb com a user postgres des del directori data i tornar a copiar pg_hba.conf
  file { $pg_hba:
    owner => postgres,
    group => postgres,
    mode => '0600',
    source => "puppet:///modules/postgres/$pg_hba_source",
    require => [ Package[$postgres], Service[$postgres_service] ],
    notify => Exec["postgres_reload"],
  }

  exec { "postgres_reload":
    command => "/etc/init.d/$postgres_service reload",
    user => root,
    refreshonly => true,
  }

  postgres::user { "root":
    ensure => present,
    superuser => true,
  }

}
