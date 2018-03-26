# nginx server
class mailserver::nginx inherits common::nginx {

  # prevent apache being installed by postfixadmin
  Package['nginx-light'] { before => Package['postfixadmin'] }

  file {
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
