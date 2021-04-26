class common::mongodb_backup_weekdays {

  cron {
    'backup mongodb':
      command => 'cd /var/backups/mongodb/ && /usr/bin/mongodump',
      user    => 'mongodb',
      weekday => ['1-5'],
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
