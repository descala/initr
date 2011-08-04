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

#TODO: /etc/amavis/conf.d/ files
#  file {
#    "/etc/amavisd/amavisd.conf":
#      mode => 644,
#      content => template("common/amavisd.conf.erb"),
#      require => Package["amavisd-new"],
#      notify => Service["amavis"];
#  }

}


