class common::postfixadmin::debian inherits common::postfixadmin {

  package {
    'postfixadmin':
      ensure => present;
  }

  file {
    '/etc/postfixadmin/config.local.php':
      mode    => '0640',
      owner   => root,
      group   => www-data,
      require => Package['postfixadmin'],
      content => template('common/postfixadmin/config.local.php.erb');
    "${::httpd_confdir}/postfixadmin":
      ensure => link,
      target => '/etc/postfixadmin/apache.conf';
  }

  case $::lsbdistcodename {
    'stretch': { include common::postfixadmin::debian::stretch }
  }

}

