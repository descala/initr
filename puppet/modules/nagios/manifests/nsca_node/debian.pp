class nagios::nsca_node::debian  inherits nagios::nsca_node::common {

  cron {
    "heartbeat":
      command => "/usr/lib/nagios/plugins/heartbeat > /dev/null 2>&1",
      user => root,
      minute => "*/5",
      require => File["/usr/lib/nagios/plugins/heartbeat"];
  }

  package {
    ["nagios-plugins-basic","nagios-plugins-standard"]:
      ensure => installed;
  }

  file {
    "/etc/send_nsca.cfg":
      mode => '0640',
      require => Package["nsca"],
      content => template("nagios/send_nsca.cfg.erb");
    "/usr/lib/nagios/plugins/heartbeat":
      mode => '0740',
      require => Package["nagios-plugins-basic"],
      content => template("nagios/heartbeat.sh.erb");
  }

}

