class nagios::nsca_node::redhat  inherits nagios::nsca_node::common {

  cron {
    "heartbeat":
      command => "/usr/local/nsca/bin/heartbeat &> /dev/null",
      user => root,
      minute => "*/5",
      require => File["/usr/local/nsca/bin/heartbeat"];
  }


  file {
    "/usr/local/src/install_nagios_plugins.sh":
      mode => 744,
      source => "puppet:///modules/nagios/install_nagios_plugins.sh";
    "/usr/local/nsca/etc/send_nsca.cfg":
      mode => 640,
      require => Exec["/usr/local/src/install_nsca.sh"],
      content => template("nagios/send_nsca.cfg.erb");
    "/usr/local/nsca/bin/heartbeat":
      mode => 740,
      require => Exec["/usr/local/src/install_nsca.sh"],
      content => template("nagios/heartbeat.sh.erb");
  }

  exec {
    "/usr/local/src/install_nagios_plugins.sh":
      require => [ Package[$libmcrypt], File["/usr/local/src/install_nagios_plugins.sh"], Package["gcc"] ],
      unless => "[ -f /usr/local/nagios/libexec/check_disk ]";
  }

}

