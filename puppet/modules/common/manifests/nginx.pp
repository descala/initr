# nginx server
class common::nginx {

  package {
    'nginx-light':
      ensure => installed;
    'php-fpm':
      ensure => installed;
  }

  service {
    'nginx':
      ensure  => running,
      enable  => true,
      require => Package['nginx-light'];
  }

  exec {
    'nginx reload':
      command     => '/etc/init.d/nginx reload',
      refreshonly => true,
      require     => Service['nginx'];
  }

  file {
    '/etc/nginx/fastcgi_params':
      content => template('mailserver/nginx_php_fpm.erb'),
      owner   => root,
      group   => root,
      mode    => '0644',
      require => Package['nginx-light'],
      notify  => Service['nginx'];
    '/etc/nginx/global.d':
      ensure  => directory,
      owner   => root,
      group   => root,
      mode    => '0755',
      require => Package['nginx-light'];
  }

}
