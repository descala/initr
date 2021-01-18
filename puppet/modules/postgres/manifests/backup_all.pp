class postgres::backup_all {

  file {
    '/var/backups/postgres/dump_all.sh':
      source => 'puppet:///modules/postgres/dump_all.sh',
      owner  => postgres,
      group  => postgres,
      mode   => '0700';
    '/var/backups/postgres':
      ensure => directory,
      owner  => postgres,
      group  => postgres,
      mode   => '0750';
  }

  cron {
    'backup postgres all db':
      command => '/var/backups/postgres/dump_all.sh'
      require => File['/var/backups/postgres/dump_all.sh'],
      user    => 'root',
      hour    => '0',
      minute  => '0';
  }

}
