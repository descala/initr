# debian specific
class bind::debian {

  file {
    $bind::var_dir:
      ensure  => directory,
      owner   => $bind::binduser,
      group   => $bind::binduser,
      mode    => '0770',
      require => Package[$bind::bind];
    "$bind::var_dir/named.conf.options":
      owner   => root,
      group   => $bind::binduser,
      mode    => '0644',
      content => template('bind/named.conf.options.erb'),
      require => Package[$bind::bind],
      notify  => Service['bind'];
    "$bind::var_dir/named.conf.options.local":
      owner   => root,
      group   => $bind::binduser,
      mode    => '0644',
      content => "",
      replace => 'no';
  }

  append_if_no_such_line { 'puppet_zones_include':
    file    => '/etc/bind/named.conf.local',
    line    => 'include "/etc/bind/puppet_zones.conf"; // line added by puppet',
    require => Package[$bind::bind],
    notify  => Service['bind'],
  }

  append_if_no_such_line { 'puppet_slave_zones_include':
    file    => '/etc/bind/named.conf.local',
    line    => 'include "/etc/bind/puppet_slave_zones.conf"; // line added by puppet',
    require => Package[$bind::bind],
    notify  => Service['bind'],
  }

}

