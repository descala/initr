class nagios::server::debian inherits nagios::server::common {

  $nagios_init_script = $::operatingsystem ? {
    'Debian'  => $::lsbmajdistrelease ? {
      '8'     => 'puppet:///modules/nagios/nagios_init_script_debian8',
      default => 'puppet:///modules/nagios/nagios_init_script_debian'
    },
    default => 'puppet:///modules/nagios/nagios_init_script_debian'
  }
  if $::lsbmajdistrelease == '7' {
    file {
      '/etc/apache2/conf.d/nagios3.conf':
        source => 'puppet:///modules/nagios/apache.conf';
    }
  }
  package {
    "nagios3":
      ensure => installed,
      alias => nagios;
  }
  service {
    "nagios3":
      enable => true,
      ensure => running,
      hasstatus => true,
      hasrestart => true,
      alias => nagios;
    "nsca":
      enable => true,
      ensure => running,
      hasstatus => false,
      hasrestart => true;
  }
  file {
    "/etc/nagios3/htpasswd.users":
      content => template("nagios/htpasswd.users.erb"),
      owner => root,
      group => $httpd_user,
      mode => '0064'0,
      require => Package["nagios3"];
    # needed for nagios external command (/usr/share/doc/nagios3/README.Debian)
    "/var/lib/nagios3":
      owner => nagios,
      group => nagios,
      mode => '0075'1,
      require => Package["nagios3"];
    # needed for nagios external command (/usr/share/doc/nagios3/README.Debian)
    "/var/lib/nagios3/rw":
      owner => nagios,
      group => www-data,
      mode => '0271'0,
      require => Package["nagios3"];
    "/etc/nagios3/nagios.cfg":
      content => template("nagios/nagios.cfg.erb"),
      notify => Service["nagios3"],
      require => Package["nagios3"];
    # puppet needs nagios conf in default dir to purge it (architectural limitation)
    "/etc/nagios3/conf.d":
      ensure => "/etc/nagios",
      backup => false,
      force => true,
      require => File["/etc/nagios"];
    "/etc/nagios3/commands.cfg":
      content => template("nagios/commands.cfg.erb"),
      require => Package["nagios3"],
      notify => Service["nagios"];
    "/etc/nsca.cfg":
      owner => nagios,
      group => $nagios_group,
      mode => '0640',
      content => template("nagios/nsca.cfg.erb"),
      require => [Package["nsca"], Package["nagios"]],
      notify => Service["nsca"];
    # Replace init.d script to check config before restart nagios daemon
    '/etc/init.d/nagios3':
      owner  => root,
      group  => root,
      mode   => '0755',
      source => $nagios_init_script;
  }
  cron {
    # http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=479330
    "purge nagios logs":
      command => "find /var/log/nagios3/archives/ -type f -mtime +180 -delete",
      hour => 6,
      minute => 40;
  }
}

