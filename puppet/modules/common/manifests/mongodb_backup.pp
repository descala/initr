class common::mongodb_backup {

  package {
    'mongodb-org-tools':
      ensure => installed;
  }

  cron {
    'backup mongodb':
      command => 'cd /var/backups/mongodb/ && /usr/bin/mongodump',
      user    => 'mongodb',
      hour    => 0,
      minute  => 30;
  }

}
