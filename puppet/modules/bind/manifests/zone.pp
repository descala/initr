define bind::zone($zone,$ttl,$serial) {

  file {
    "$bind::var_dir/puppet_zones/$name.zone":
      owner => $bind::binduser,
      group => $bind::binduser,
      mode => '0640',
      content => template("bind/zone.erb"),
      require => [Package[$bind::bind],File["$bind::var_dir/puppet_zones"]],
      notify => Service[$bind::bind];
  }
}

