# backups amb Borg
class borg_backup($borg_passphrase,$repository,$excludes,$paths,$hour,$minute,
                  $keep_daily,$keep_weekly,$keep_monthly,$keep_yearly) {

  include copier::mysqldump
  include postgres::backup_all

  package {
    'borgbackup':
      ensure => installed;
  }

  file {
    '/etc/logrotate.d/borgbackups':
      mode   => '0644',
      owner  => root,
      group  => root,
      source => 'puppet:///modules/borg_backup/logrotate.conf';
    '/usr/local/sbin/borg_backup.sh':
      mode    => '0700',
      owner   => root,
      group   => root,
      content => template('borg_backup/borg_backup.sh.erb');
    '/root/.ssh':
      ensure => directory,
      mode   => '0700',
      owner  => root,
      group  => root;
    '/var/log/borg/':
      ensure => directory,
      mode   => '0755',
      owner  => root,
      group  => root;
  }

  exec {
    'generate ssh key':
      command => 'ssh-keygen -t rsa -C "generated by puppet for borg backups" -N "" -f /root/.ssh/borg_rsa',
      creates => '/root/.ssh/borg_rsa',
      require => File['/root/.ssh'];

  }

  cron {
    # TODO: random delay?
    'borg backup':
      command => '/usr/local/sbin/borg_backup.sh',
      hour    => $hour,
      minute  => $minute,
      user    => root;
  }

  if array_includes($::classes, 'nagios::nsca_node') {
    nagios::service { "borg_backup_${::fqdn}":
      ensure    => present,
      freshness => 93600;
    }
  }

}
