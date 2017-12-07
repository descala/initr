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
    'update amavis local_domains':
      command => '/usr/local/sbin/amavis_update_local_domains.sh',
      user    => root,
      hour    => 5,
      minute  => 45;
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
    '/usr/local/sbin/amavis_update_local_domains.sh':
      source => 'puppet:///modules/common/amavis/amavis_update_local_domains.sh',
      mode   => "0700";
    '/etc/amavis/local_domains':
      ensure  => present,
      require => Package['amavisd-new'];
    '/etc/amavis/conf.d/40-local_domains':
      source  => 'puppet:///modules/common/amavis/40-local_domains',
      mode    => "0644",
      require => Package['amavisd-new'],
      notify  => Service['amavis'];
  }

  # see https://git.dotlan.net/dhoffend/kolab/blob/master/debian-install/4.8_amavis-spamassassin.sh
  delete_if_such_lines { amavis_local_domains:
    file    => '/etc/amavis/conf.d/50-user',
    line    => '@local_domains_acl = ( read_hash(\%local_domains, "/etc/amavis/local_domains") );',
    require => Package['amavisd-new'],
    notify  => Service['amavis'];
  }

}
