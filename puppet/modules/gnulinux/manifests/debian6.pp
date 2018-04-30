class gnulinux::debian6 inherits gnulinux::debian {

  if $is_virtual != "true" {
    package {
      "firmware-linux-nonfree":
        ensure => present;
    }
  }

  # http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=380425
  # al actualitzar el paquet automàticament amb force-confold
  # aquest fitxer no s'havia actualitzat
  if $raidtype == "software" {
    file {
      "/etc/cron.d/mdadm":
        mode => '0644',
        source => "puppet:///modules/gnulinux/debian/cron_mdadm";
    }
  }

  File["/etc/apt/auto_upgrade"] {
    source => ["puppet:///specific/auto_upgrade", "puppet:///modules/gnulinux/debian/auto_upgrade_debian6"]
  }

}

