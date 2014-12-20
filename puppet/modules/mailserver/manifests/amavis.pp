class mailserver::amavis {
  class { 'common::amavis':
    db_name   => $::db_name,
    db_user   => $::db_user,
    db_passwd => $::db_passwd,
  }
  file {
    '/etc/mail/spamassassin/sasl_authenticated.cf':
      mode    => '0644',
      content => template('mailserver/sasl_authenticated.cf.erb'),
      require => Package['spamassassin'],
      notify  => Service['amavis'];
    '/etc/postfix/recipient_access':
      mode    => '0644',
      source  => [ 'puppet:///specific/recipient_access', 'puppet:///modules/mailserver/recipient_access' ],
      notify  => Exec['postmap_ra'],
      require => Package['postfix'];
  }
  service {
    'spamassassin':
      ensure    => stopped, # spamassassin runs through amavisd
      enable    => false,
      hasstatus => true,
      require   => Package['spamassassin'];
  }
  if $::clamav == '1' {
    exec {
      '/usr/bin/gpasswd -a clamav amavis':
        require => [Package['amavisd-new'],Package['clamav']],
        notify  => Service['amavis'],
        onlyif  => 'test -z \'`groups clamav |grep amavis`\'';
    }
  }
  package {
    'spamassassin':
      ensure => installed;
  }
}
