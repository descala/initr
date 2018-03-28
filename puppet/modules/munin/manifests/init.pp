class munin {


  case $operatingsystem {
    # to avoid this message in mandriva
    #  Could not get latest version: Execution of '/usr/bin/urpmq -S munin-node' returned 1: urpmq: unknown option "-S", check usage with --help
    "Mandriva": {
      package { $munin:
        ensure => installed,
      }
    }
    default: {
      package { $munin:
        ensure => latest,
      }
    }
  }

  service { "munin-node":
    enable => true,
    ensure => running,
    subscribe => [ Package[$munin],
                   File["/etc/munin/munin-node.conf"] ],
  }

  file {
    "/etc/munin/munin-node.conf":
      content => template("munin/munin-node.conf.erb"),
      require => Package[$munin],
      notify => Service["munin-node"];
    "/usr/share/munin/plugins/shorewall_accounting":
      mode => '0755',
      source => "puppet:///modules/munin/shorewall_accounting",
      require => Package[$munin];
  }

  case $drives {
    false, "false", "no", "", undef: {}
    default: {
      file { "/etc/munin/plugin-conf.d/hddtemp_smartctl":
        content => template("munin/hddtemp_smartctl.erb"),
        notify => Service["munin-node"],
        require => Package[$munin],
      }
    }
  }

  # don't purge plugins dir if manual config
  if !array_includes($munin_checks,"munin_manual") {
    file {
      "/etc/munin/plugins":
        owner => munin,
        group => munin,
        ensure => directory,
        require => Package[$munin],
        source => "puppet:///modules/munin/plugins",
        recurse => true,
        ignore => ".gitignore",
        purge => true,
        backup => false;
    }
    # don't use create_resources since $munin_checks is an array,
    # puppet accepts arrays on resource definition
    munin::plugin { $munin_checks: }
  }

}

