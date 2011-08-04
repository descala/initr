class common::cron {

  service {
    $cron_service:
      hasrestart => true,
      hasstatus => false,
      path => "/etc/init.d/",
      ensure => running,
      enable => true;
  }

}
