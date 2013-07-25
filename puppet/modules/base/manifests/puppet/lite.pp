class base::puppet::lite inherits base::puppet {
  if $operatingsystem == "Fedora" or $operatingsystem == "Mandriva" {
    Service["puppet"] {
      enable => false,
      # use a pattern to check if puppet is running daemonized or with "puppetd -o"
      hasstatus => false,
      pattern => $puppetversion ? {
        /^0\./ => "puppetd$",
        default => "puppet agent",
      },
      ensure => stopped,
    }
  } else {
    Service["puppet"] {
      enable    => false,
      hasstatus => true,
      ensure    => stopped,
    }
  }

  File["/usr/local/sbin/puppet-restart.sh"] {
    source => ["puppet:///specific/puppet-restart.sh","puppet:///modules/base/puppet/puppet-lite-restart.sh"],
    before => Service["puppet"],
  }
  if array_includes($classes,"nagios::nsca_node") {
    # Should run every 24 hours
    Nagios::Check["puppet_last_run"] {
      command => "check_file_age -w 100000 -c 200000 -f /var/lib/puppet/state/state.yaml",
    }
  }
}

