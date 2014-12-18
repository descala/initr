class mailserver::common {

  # sense PAM
  #  $::db_passwd_encrypt_pam="0" # md5crypt=, md5=3, system=, cleartext=0

  include "mailserver::${::webserver}"
  include "mailserver::${::db_backend}"
  include "mailserver::${::webmail}"

  if $::db_backend == 'postgres' {
    $db_driver = 'pgsql'
  } else {
    $db_driver = 'mysql'
  }

  class { 'common::dovecot':
    db_name           => $::db_name,
    db_user           => $::db_user,
    db_passwd         => $::db_passwd,
    db_passwd_encrypt => $::db_passwd_encrypt,
    mail_location     => $::mail_location,
    admin_mail        => $::admin_email,
    db_backend        => $::db_backend,
  }

  class { 'common::postfixadmin':
    db_name             => $::db_name,
    db_user             => $::db_user,
    db_passwd           => $::db_passwd,
    postfixadmin_user   => 'admin@localhost.loc',
    postfixadmin_passwd => 'changeme',
    admin_email         => $::admin_email,
    db_passwd_encrypt   => $::db_passwd_encrypt,
    bak_host            => $::bak_host,
    domain_in_mailbox   => $::domain_in_mailbox,
    domain_path         => $::domain_path,
    db_backend          => $::db_backend,
  }

  if $::clamav == '1' {
    include common::clamav
  }

  if $::amavis == '1' {
    include mailserver::amavis
  }

  if array_includes($::classes,'nagios::nsca_node') {
    include mailserver::nagios
  }

  package {
    ['pfqueue','spamassassin','postfix','postgrey']:
      ensure => installed;
    ['sendmail','exim']:
      ensure => absent;
  }

  user {
    'vmail':
      ensure  => present,
      comment => 'Virtual mailbox (Puppet managed)',
      uid     => 201,
      gid     => mail,
      home    => $::mail_location,
      shell   => '/sbin/nologin';
  }
  
  service {
    ['postfix','postgrey']:
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
      require    => Package['postfix'];
  }

  file {
    $::mail_location:
      ensure  => directory,
      mode    => '0770',
      owner   => vmail,
      group   => mail,
      require => User['vmail'];
    '/etc/postfix/aliases.pcre':
      mode    => '0644',
      replace => no,
      source  => 'puppet:///modules/mailserver/aliases.pcre',
      require => Package['postfix'];
    '/etc/postfix/sql-virtual-aliases.cf':
      mode    => '0640',
      group   => postfix,
      content => template('mailserver/sql-virtual-aliases.cf.erb'),
      notify  => Service['postfix'],
      require => Package['postfix'];
    '/etc/postfix/sql-virtual-aliases-postmaster.cf':
      mode    => '0640',
      group   => postfix,
      content => template('mailserver/sql-virtual-aliases-postmaster.cf.erb'),
      notify  => Service['postfix'],
      require => Package['postfix'];
    '/etc/postfix/sql-virtual-domains.cf':
      mode    => '0640',
      group   => postfix,
      content => template('mailserver/sql-virtual-domains.cf.erb'),
      notify  => Service['postfix'],
      require => Package['postfix'];
    '/etc/postfix/sql-virtual-mailbox.cf':
      mode    => '0640',
      group   => postfix,
      content => template('mailserver/sql-virtual-mailbox.cf.erb'),
      notify  => Service['postfix'],
      require => Package['postfix'];
    '/etc/postfix/recipient_access':
      mode    => '0644',
      source  => [ 'puppet:///specific/recipient_access', 'puppet:///modules/mailserver/recipient_access' ],
      notify  => Exec['postmap_ra'],
      require => Package['postfix'];
    '/etc/postfix/recipient_greylist':
      mode    => '0644',
      source  => [ 'puppet:///specific/recipient_st', 'puppet:///modules/mailserver/recipient_greylist' ],
      notify  => Exec['postmap_rg'],
      require => Package['postfix'];
    '/etc/postfix/recipient_bcc':
      mode    => '0644',
      replace => false,
      source  => [ 'puppet:///modules/mailserver/recipient_bcc' ],
      notify  => Exec['postmap_bcc'],
      require => Package['postfix'];
    '/etc/postfix/sender_bcc':
      mode    => '0644',
      replace => false,
      source  => [ 'puppet:///modules/mailserver/sender_bcc' ],
      notify  => Exec['postmap_bcc'],
      require => Package['postfix'];
    '/etc/aliases':
      notify => Exec['/usr/sbin/postalias /etc/aliases'];
    '/etc/postfix/master.cf':
      mode    => '0644',
      source  => 'puppet:///modules/mailserver/master.cf',
      notify  => Service['postfix'],
      require => Package['postfix'];
    '/etc/postfix/main.cf':
      mode    => '0644',
      content => template('mailserver/main.cf.erb'),
      notify  => Service['postfix'],
      require => Package['postfix'];
    }

  exec {
    '/usr/sbin/postalias /etc/aliases':
      creates => '/etc/aliases.db',
      require => Package['postfix'];
    '/usr/sbin/postmap /etc/postfix/aliases.pcre':
      subscribe   => File['/etc/postfix/aliases.pcre'],
      refreshonly => true,
      notify      => Service['postfix'];
    '/usr/sbin/postmap /etc/postfix/recipient_access':
      alias       => 'postmap_ra',
      refreshonly => true,
      require     => Package['postfix'];
    '/usr/sbin/postmap /etc/postfix/recipient_greylist':
      alias       => 'postmap_rg',
      refreshonly => true,
      require     => Package['postfix'];
    '/usr/sbin/postmap /etc/postfix/recipient_bcc /etc/postfix/sender_bcc':
      alias       => 'postmap_bcc',
      refreshonly => true,
      require     => Package['postfix'];
  }


}
