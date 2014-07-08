class common::amavis::debian inherits common::amavis::common {

  service {
    'amavis':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
      require    => Package['amavisd-new'];
  }

  cron {
    'purge quarantine':
      command => 'find /var/lib/amavis/virusmails/ -type f -ctime +30 -delete',
      user    => root,
      hour    => 6,
      minute  => 15;
  }

  file {
    '/etc/amavis/conf.d/15-content_filter_mode':
      source  => ['puppet:///specific/amavis-15-content_filter_mode','puppet:///modules/common/amavis/15-content_filter_mode'],
      mode    => '0644',
      require => Package['amavisd-new'],
      notify  => Service['amavis'];
    # now it's on /etc/cron.d/amavisd-new
    # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=671450
    '/etc/cron.daily/amavisd-new':
      ensure => absent;
  }

}

