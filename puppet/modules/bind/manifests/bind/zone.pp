define bind::zone($zone,$ttl,$serial) {

  if array_includes($classes,"nagios::nsca_node") {
    nagios::service {
      "check_dig_$name":
        checkfreshness => "1",
        freshness => "1800",
        ensure => present,
        notifications_enabled => "0";
    }
  }

  file {
    "$bind::var_dir/puppet_zones/$name.zone":
      owner => $binduser,
      group => $binduser,
      mode => 640,
      content => template("bind/zone.erb"),
      require => [Package[$bind],File["$bind::var_dir/puppet_zones"]],
      notify => Service[$bind];
  }
}

