# nginx server
class mailserver::nginx {

  if $::webserver == 'nginx' {
    # prevent apache being installed by postfixadmin
    package {
      'nginx-light':
        ensure => installed,
        before => Package['postfixadmin'];
    }
  } else {
    package {
      'nginx-light':
        ensure => installed;
    }
  }

  package {
    "php-fpm":
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
      source  => 'puppet:///modules/mailserver/nginx_php_fpm',
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
    '/etc/nginx/global.d/postfixadmin.conf':
      source => 'puppet:///modules/mailserver/nginx_postfixadmin.conf',
      owner   => root,
      group   => root,
      mode    => '0644',
      require => File['/etc/nginx/global.d'],
      notify  => Service['nginx'];
  }

  if $::webmail == 'roundcube' {
    file {
      '/etc/nginx/global.d/roundcube.conf':
        source => 'puppet:///modules/mailserver/nginx_roundcube.conf',
        owner   => root,
        group   => root,
        mode    => '0644',
        require => File['/etc/nginx/global.d'],
        notify  => Service['nginx'];
    }
    } else {
      #TODO squirrelmail
      }

}
