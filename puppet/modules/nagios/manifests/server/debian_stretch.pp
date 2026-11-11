class nagios::server::debian_stretch inherits nagios::server::common {

  package {
    "icinga":
      ensure => installed,
      alias => nagios;
  }
  service {
    "icinga":
      enable => true,
      ensure => running,
      hasstatus => true,
      hasrestart => true,
      # Validate first. The init script stops the daemon and only then runs its
      # own pre-flight check, so a restart with a broken config (e.g. an object
      # pointing at a contact group that no longer exists) leaves monitoring
      # down. This way the running daemon keeps the old config and Puppet
      # reports the failed refresh, with the icinga -v output in the log.
      restart => "/usr/sbin/icinga -v /etc/icinga/icinga.cfg && /bin/systemctl restart icinga",
      alias => nagios;
    "nsca":
      enable => true,
      ensure => running,
      hasstatus => false,
      hasrestart => true;
  }
  file {
    "/etc/icinga/htpasswd.users":
      content => template("nagios/htpasswd.users.erb"),
      owner => root,
      group => $httpd_user,
      mode => '0640',
      require => Package["icinga"];
    "/var/lib/icinga":
      owner => nagios,
      group => nagios,
      mode => '0751',
      require => Package["icinga"];
    "/var/lib/icinga/rw":
      owner => nagios,
      group => www-data,
      mode => '2710',
      require => Package["icinga"];
    "/etc/icinga/icinga.cfg":
      content => template("nagios/icinga.cfg.erb"),
      notify => Service["icinga"],
      require => Package["icinga"];
     # puppet needs nagios conf in default dir to purge it (architectural limitation)
    "/etc/icinga/conf.d":
      ensure => "/etc/nagios",
      backup => false,
      force => true,
      require => File["/etc/nagios"];
    # "/etc/icinga/commands.cfg":
    #   content => template("nagios/commands.cfg.erb"),
    #   require => Package["icinga"],
    #   notify => Service["icinga"];
    "/etc/nsca.cfg":
      owner => nagios,
      group => $nagios_group,
      mode => '0640',
      content => template("nagios/nsca_icinga.cfg.erb"),
      require => [Package["nsca"], Package["icinga"]],
      notify => Service["nsca"];
  }
  cron {
    # http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=479330
    "purge icinga logs":
      command => "find /var/log/icinga/archives/ -type f -mtime +180 -delete",
      hour => 6,
      minute => 40;
  }
}

