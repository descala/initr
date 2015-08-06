# Deploys https://github.com/glensc/nagios-plugin-check_raid

class nagios::check_raid {
  file {
    "$nagios_plugins_dir/check_raid.pl":
      mode => 755,
      source => "puppet:///modules/nagios/check_raid.pl";
  }
  nagios::nsca_node::wrapper_check {
    "check_raid":
      command => "$nagios_plugins_dir/check_raid.pl";
  }
}

