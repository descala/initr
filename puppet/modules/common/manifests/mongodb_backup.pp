class common::mongodb_backup {

  cron {
    'backup mongodb':
      command => 'cd /var/backups/mongodb/ && /usr/bin/mongodump',
      user    => 'mongodb',
      hour    => 0,
      minute  => 30;
  }

  file {
    '/var/backups/mongodb':
      ensure => directory,
      owner  => mongodb,
      group  => nogroup,
      mode   => '0755';

  }

}
