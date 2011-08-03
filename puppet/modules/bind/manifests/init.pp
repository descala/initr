class bind {
  $osavn = "$lsbdistid$lsbdistrelease_class"
  case $operatingsystem {
    Debian,Ubuntu: {
      $etc_dir = "/etc/bind"
      $var_dir = $etc_dir
      include bind::debian
    }
    default: {
      $bind_base_dir = $osavn ? {
        "MandrivaLinux2006_0" => "/var/lib/named",
        default => ""
      }
      $etc_dir = "$bind_base_dir/etc"
      $var_dir = "$bind_base_dir/var/named"
      include bind::redhat
    }
  }

  # common definitions
  
  package {
    $bind:
      ensure => installed;
  }

  service {
    $bindservice:
      ensure => running,
      enable => true,
      hasrestart => true,
      hasstatus => true,
      require => Package[$bind],
      alias => bind;
  }

  file {
    "$var_dir/puppet_zones":
      owner => $binduser,
      group => $binduser,
      require => [File["$var_dir"],Package[$bind]],
      purge => true,
      force => true,
      recurse => true,
      ignore => ".gitignore",
      source => "puppet:///modules/bind/empty",
      mode => 770;
    "$var_dir/puppet_zones.conf":
      owner => root,
      group => $binduser,
      mode => 644,
      notify => Service["bind"],
      require => Package[$bind],
      content => template("bind/puppet_zones.conf.erb");
  }

  if array_includes($classes,"nagios::nsca_node") {
    file {
      "/usr/local/bin/nagios_check_dig.sh":
        owner => root, group => root, mode => 700,
        content => template("bind/nagios_check_dig.sh.erb");
    }
    cron {
      "check dig all domains":
        command => "/usr/local/bin/nagios_check_dig.sh &> /dev/null",
        user => root,
        minute => "*/15",
        ensure => present;
    }
  }

  create_resources(bind::zoneconf, $bind_masterzones)

}

