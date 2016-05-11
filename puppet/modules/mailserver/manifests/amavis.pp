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
    '/etc/mail/spamassassin/90_puppet_custom_rules.cf':
      mode    => '0644',
      source  => [ 'puppet:///modules/mailserver/90_puppet_custom_rules.cf' ],
      require => Package['spamassassin'],
      notify  => Service['amavis'];
    '/etc/mail/spamassassin/90_clamav_scores.cf':
      mode    => '0644',
      source  => [ 'puppet:///modules/mailserver/90_clamav_scores.cf' ],
      require => Package['spamassassin'],
      notify  => Service['amavis'];
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
