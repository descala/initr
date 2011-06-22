import "*.pp"

class nagios::nsca_node {
  case $operatingsystem {
    Debian: {
      case $lsbdistcodename {
        # dapper has bug in package nagios-plugins-basic (check_procs plugin)
        dapper: { include nagios::nsca_node::redhat }
        default: { include nagios::nsca_node::debian }
      }
    }
    default: { include nagios::nsca_node::redhat }
  }
  case $raidtype {
    "software","software hardware": { include nagios::swraid }
  }
}

class nagios::nsca_node::common {

  include build_essential
  include nagios::nsca

  # freshness_threshold is 950 in 'passive-host' template
  @@nagios_host { $fqdn:
    use => "passive-host",
    contact_groups => $nagios_contact_groups,
    notify => Service["nagios"],
    tag => $nagios_server
  }

  nagios::service { "uptime": }
  nagios::check { $nagios_checks: }

  package {
    $libmcrypt:
      ensure => present;
  }

  file {
    "/usr/local/bin/nsca_wrapper":
      mode => 744,
      content => template("nagios/nsca_wrapper.erb");
    "/usr/local/bin/nsca_send":
      mode => 740,
      content => template("nagios/nsca_send.erb");
    "/usr/local/nsca/bin/send":
      ensure => absent; # file above replaces this
  }

}

class nagios::nsca_node::debian  inherits nagios::nsca_node::common {

  cron {
    "heartbeat":
      command => "/usr/lib/nagios/plugins/heartbeat &> /dev/null",
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
      mode => 640,
      require => Package["nsca"],
      content => template("nagios/send_nsca.cfg.erb");
    "/usr/lib/nagios/plugins/heartbeat":
      mode => 740,
      require => Package["nagios-plugins-basic"],
      content => template("nagios/heartbeat.sh.erb");
  }

}

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

class nagios::ssl_cert {
  file {
    "$nagios_plugins_dir/check_ssl_cert":
      mode => 755,
      source => "puppet:///modules/nagios/check_ssl_cert";
  }
  package {
    $ca_certificates:
      ensure => installed;
  }
}

class nagios::swraid {
  file {
    "$nagios_plugins_dir/check_swraid":
      mode => 755,
      source => "puppet:///modules/nagios/check_swraid";
  }
  nagios::nsca_node::wrapper_check {
    "sw_raid":
      command => "$nagios_plugins_dir/check_swraid";
  }
}

class nagios::check_blacklisted {
  include perl
  file {
    "$nagios_plugins_dir/check_bl":
      mode => 755,
      source => "puppet:///modules/nagios/check_bl";
  }
  if $check_bl_ip {
    # Define ip on initr
    nagios::nsca_node::wrapper_check {
      "blacklisted":
        command => "$nagios_plugins_dir/check_bl -H $check_bl_ip zen.spamhaus.org,dnsbl.njabl.org",
        minute => "*/30",
        freshness => "6000";
    }
  } else {
    if array_includes($classes,"dyndns") {
      # Dynamic IP address with dyndns module
      nagios::nsca_node::wrapper_check {
        "blacklisted":
          command => "$nagios_plugins_dir/check_bl -H $fqdn.$ddns_domain zen.spamhaus.org,dnsbl.njabl.org",
          minute => "*/30",
          freshness => "6000";
      }
    } else {
      # Host with static ip_address
      nagios::nsca_node::wrapper_check {
        "blacklisted":
          command => "$nagios_plugins_dir/check_bl -H $ipaddress_internet zen.spamhaus.org,dnsbl.njabl.org",
          minute => "*/30",
          freshness => "6000";
      }
    }
  }
}

class nagios::check_router {

  @@nagios_host { "${fqdn}_router":
    use => "generic-switch",
    contact_groups => $nagios_contact_groups,
    notify => Service["nagios"],
    tag => $nagios_server,
    address => "${fqdn}.${ddns_domain}",
  }

}

define nagios::service( $checkfreshness="1", $freshness="1800", $ensure="present", $notifications_enabled="1") {
  @@nagios_service { "${fqdn}_$name":
    use => "passive_service",
    host_name => $fqdn,
    check_freshness => $checkfreshness,
    freshness_threshold => $freshness,
    check_command => "check_stale!1!'This service is stale'",
    notify => Service["nagios"],
    ensure => $ensure,
    notifications_enabled => $notifications_enabled,
    service_description => $name,
    contact_groups => $nagios_contact_groups,
    tag => $nagios_server
  }
}

define nagios::nsca_node::wrapper_check($command, $checkfreshness="1", $freshness="1800", $minute="*/5", $hour="*", $ensure="present", $notifications_enabled="1",$sleep="--sleep") {

  nagios::service { $name:
    checkfreshness => $checkfreshness,
    freshness => $freshness,
    ensure => $ensure,
    notifications_enabled => $notifications_enabled,
  }

  $nsca_command = "/usr/local/bin/nsca_wrapper -H $fqdn -S '$name' -C '$command' $sleep -b $send_nsca -c $send_nsca_cfg &> /dev/null"

  # bug: http://projects.reductivelabs.com/issues/1728
  case $hour {
    "*": {
      cron { "nagios $name":
        command => $nsca_command,
        user => root,
        minute => $minute,
        require => File["/usr/local/bin/nsca_wrapper"],
        ensure => $ensure,
      }
    }
    default: {
      cron { "nagios $name":
        command => $nsca_command,
        user => root,
        minute => $minute,
        hour => $hour,
        require => File["/usr/local/bin/nsca_wrapper"],
        ensure => $ensure,
      }
    }
  }
}

define nagios::check($command, $checkfreshness="1", $freshness="1800", $minute="*/5", $hour="*", $ensure="present", $notifications_enabled="1") {
  nagios::nsca_node::wrapper_check { $name:
    command => "$nagios_plugins_dir/$command",
    checkfreshness => $checkfreshness,
    freshness => $freshness,
    minute => $minute,
    hour => $hour,
    ensure => $ensure,
    notifications_enabled => $notifications_enabled,
  }
}

