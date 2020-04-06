# vacation system for mailserver
# manual configuration needed:
#   cd /usr/share/roundcube/plugins/
#   git clone https://github.com/lluis/rc-vacation.git vacation
#   cd /var/lib/roundcube/plugins/
#   ln -s /usr/share/roundcube/plugins/vacation/
class mailserver::vacation {

  include common::perl

  if $::db_backend == 'postgres' {
    $db_driver = 'Pg'
    $db_lib_package = 'libdbd-pg-perl'
  } else {
    $db_driver = 'mysql'
    $db_lib_package = 'libdbd-mysql-perl'
  }

  user {
    'vacation':
      ensure  => present,
      comment => 'puppet managed user for mail vacation system',
      shell   => '/bin/false',
      system  => true;
  }

  file {
    '/var/spool/vacation':
      ensure  => directory,
      owner   => 'vacation',
      mode    => '0555',
      require => User['vacation'];
    '/var/spool/vacation/vacation.pl':
      source  => 'puppet:///modules/mailserver/vacation.pl',
      owner   => 'vacation',
      mode    => '0500',
      require => [File['/var/spool/vacation'], User['vacation']];
    '/etc/postfixadmin/vacation.conf':
      content => template('mailserver/vacation.conf.erb'),
      owner   => 'vacation',
      mode    => '0700',
      require => [User['vacation'],Package['postfixadmin']];
    '/var/log/vacation.log':
      ensure  => present,
      owner   => 'vacation',
      require => User['vacation'];
  }

  append_if_no_such_line { 'vacation_transport':
    file    => '/etc/postfix/transport',
    line    => 'autoreply.localhost    vacation:',
    require => Package['postfix'],
    notify  => Exec['/usr/sbin/postmap /etc/postfix/transport'],
  }

  package {
    ['libemail-sender-perl', 'libemail-simple-perl', 'libemail-valid-perl',
    'libtry-tiny-perl', 'libdbd-pg-perl', 'libemail-mime-perl',
    'liblog-log4perl-perl', 'liblog-dispatch-perl', 'libgetopt-argvfile-perl',
    'libmime-charset-perl', 'libmime-encwords-perl', $db_lib_package]:
      ensure => installed;
  }

}
