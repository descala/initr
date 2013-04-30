class nagios::check_blacklisted {
  include common::perl
  file {
    "$nagios_plugins_dir/check_bl":
      mode => 755,
      source => "puppet:///modules/nagios/check_bl";
  }
  if $check_bl_ip {
    # Define ip on initr
    nagios::nsca_node::wrapper_check {
      "blacklisted":
        command => "$nagios_plugins_dir/check_bl -H $check_bl_ip zen.spamhaus.org",
        minute => "*/30",
        freshness => "6000";
    }
  } else {
    if array_includes($classes,"dyndns") {
      # Dynamic IP address with dyndns module
      nagios::nsca_node::wrapper_check {
        "blacklisted":
          command => "$nagios_plugins_dir/check_bl -H $fqdn.$ddns_domain zen.spamhaus.org",
          minute => "*/30",
          freshness => "6000";
      }
    } else {
      # Host with static ip_address
      nagios::nsca_node::wrapper_check {
        "blacklisted":
          command => "$nagios_plugins_dir/check_bl -H $ipaddress_internet zen.spamhaus.org",
          minute => "*/30",
          freshness => "6000";
      }
    }
  }
}

