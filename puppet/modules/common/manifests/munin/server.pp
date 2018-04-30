# munin server
class common::munin::server {

  package {
    ['munin','libcgi-fast-perl']:
      ensure => latest;
  }

  file {
    '/var/www/html/munincgi':
      ensure => directory,
      mode   => '0770',
      owner  => munin,
      group  => $httpd_user;
    '/var/log/munin/munin-graph.log':
      ensure => present,
      owner  => munin,
      group  => $httpd_user,
      mode   => '0660',
      require => Package['munin'];
    '/var/log/munin/munin-cgi-graph.log':
      ensure => present,
      owner  => munin,
      group  => $httpd_user,
      mode   => '0660',
      require => Package['munin'];
    '/usr/share/munin/munin-html':
      content => '#!/usr/bin/perl', # avoid html generation http://munin-monitoring.org/ticket/949
      mode    => '0755',
      require => Package['munin'];
    '/var/log/munin':
      ensure => directory,
      owner  => munin,
      group  => www-data,
      mode   => '0750';
  }

  case $operatingsystem {
    'Debian': {
      file { '/etc/apache2/sites-available/munin':
        notify => Service[$httpd_service],
        content => template('common/munin/httpd.conf.erb');
      }
      common::apache::ensite { 'munin': }
    }
    default: {
      file { '/etc/httpd/conf.d/munin.conf':
        notify => Service[$httpd_service],
        content => template('common/munin/httpd.conf.erb');
      }
    }
  }

}
