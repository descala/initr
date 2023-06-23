# Posa un cron que fa un dump de tots els mysql

class copier::mysqldump {
  cron {
    'mysqldump_de_tot':
      command => '/usr/local/sbin/mysqldump_de_tot > /dev/null',
      minute  => '0',
      hour    => '2',
      user    => root,
      require => File['/usr/local/sbin/mysqldump_de_tot'],
  }
  file {
    '/usr/local/sbin/mysqldump_de_tot':
      mode => '0755',
      source => 'puppet:///modules/copier/mysqldump_de_tot';
  }
  file {
    ["/backup", "/backup/mysqldumps"]:
      mode => '0750',
      ensure => directory,
  }
}
