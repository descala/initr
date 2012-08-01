class common::amavis::debian inherits common::amavis::common {

  service {
    "amavis":
      enable => true,
      ensure => running,
      hasrestart => true,
      hasstatus => true,
      require => Package["amavisd-new"];
  }

  cron {
    "purge quarantine":
      command => "find /var/lib/amavis/virusmails/ -type f -ctime +30 -delete",
      user => root,
      hour => 6,
      minute => 15;
  }

  file {
    "/etc/amavis/conf.d/15-content_filter_mode":
      source => ["puppet:///specific/amavis-15-content_filter_mode","puppet:///modules/common/amavis/15-content_filter_mode"],
      mode => 644,
      require => Package["amavisd-new"],
      notify => Service["amavis"];
  }

}

