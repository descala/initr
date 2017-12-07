class base::puppet {
  case $operatingsystem {
    "CentOS","Fedora","Mandriva": {
      # puppet < 0.25 install from rubygems or source
      #TODO: newer versions of these OS have puppet > 0.25, check which ones.
    }
    default: {
      package {
        ["puppet","facter"]:
          ensure => installed,
          notify => Service["puppet"];
      }
    }
  }
  service {
    "puppet":
      enable => true,
      ensure => running;
  }
  file {
    "/usr/local/sbin/puppet-restart.sh":
      owner => root,
      group => root,
      mode => "0744",
      before => Service["puppet"],
      source => ["puppet:///specific/puppet-restart.sh","puppet:///modules/base/puppet/puppet-restart.sh"];
  }
  cron {
    puppet_restart:
      command => "/usr/local/sbin/puppet-restart.sh > /dev/null",
      before => Service["puppet"],
      user => root,
      hour => 5,
      minute => 10;
    "check_configuration_changes":
      command => "/usr/local/sbin/puppet-run-if-needed.sh > /dev/null 2>&1",
      before => Service["puppet"],
      ensure => absent;
  }
  if array_includes($classes,"nagios::nsca_node") {
    # Should run every 30 minutes
    nagios::check { "puppet_last_run":
      command => "check_file_age -w 7200 -c 14400 -f /var/lib/puppet/state/state.yaml",
      notifications_enabled => 0,
    }
  }
}

