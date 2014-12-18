class mailserver::squirrelmail {
  package {
    'squirrelmail':
      ensure => 'installed';
  }
  file {
    '/etc/squirrelmail/config_local.php':
      mode    => '0640',
      group   => $::httpd_user,
      source  => [ 'puppet:///specific/squirrelmail.conf.php', 'puppet:///modules/mailserver/squirrelmail.conf' ],
      require => Package['squirrelmail'];
  }
}
