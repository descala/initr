class mailserver::mysql {
  include common::mysql
  cron {
    'maildb-bak':
      command => 'mysqldump $::db_name > /root/maildb-bak.sql',
      user    => root,
      hour    => 3,
      minute  => 0,
      require => Service[$::mysqld];
    'maildb-scp':
      command => '/usr/bin/scp /root/maildb-bak.sql backup_$::hostname@$::bak_host:/var/arxiver/backups/backup_$::hostname/backup_mail_$::hostname/',
      user    => root,
      hour    => 3,
      minute  => 15,
      require => Cron['maildb-bak'];
  }
  common::mysql::database { $::db_name:
    ensure    => present,
    owner     => $::db_user,
    passwd    => $::db_passwd,
    require   => Package['postfixadmin'];
  }
  package {
    'postfix-mysql':
      ensure => installed,
      notify => Service['postfix'];
  }
}
