class mailserver::apache {
#  include common::apache
#  include common::php
#  append_if_no_such_line { 'httpd_virtualhosts':
#    file    => $::httpd_conffile,
#    line    => 'NameVirtualHost *:80',
#    require => Package[$::httpd],
#    notify  => Service[$::httpd],
#  }
#  package {
#    'libapache2-mod-php5':
#      ensure => installed,
#      notify => Service[$::httpd_service];
#    'php5-imap':
#      ensure => installed,
#      notify => Service[$::httpd_service];
#    ['libgd-graph3d-perl','postfix-pcre']:
#      ensure  => installed,
#      require => Package['postfix'];
#  }
#  file {
#    '/etc/apache2/conf.d/squirrelmail.conf':
#      ensure => link,
#      target => '/etc/squirrelmail/apache.conf',
#      notify => Service[$::httpd_service];
#  }
}
