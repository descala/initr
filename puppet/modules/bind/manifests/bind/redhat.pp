# redhat specific
class bind::redhat {


  file {
    "$bind::var_dir":
      ensure => directory,
      owner => root,
      group => $binduser,
      mode => 750;
    "$bind::etc_dir/named.conf":
      mode => 644,
      owner => root,
      group => root,
      source => [ "puppet:///specific/bind-named.conf", "puppet:///modules/bind/named.conf" ],
      notify => Service["bind"],
      require => Package[$bind];
    "$bind::var_dir/zones.conf":
      # do not overwrite file, let it be manualy modified
      replace => no,
      mode => 644,
      owner => named,
      group => named,
      source => [ "puppet:///specific/bind-zones.conf", "puppet:///modules/bind/zones.conf" ],
      notify => Service["bind"],
      require => Package[$bind];
  }

  define bind_etc_file() {
    file { "$bind::etc_dir/$name":
      mode => 644, owner => root, group => root,
      source => [ "puppet:///modules/bind/$name" ],
      notify => Service["bind"],
      require => Package[$bind],
    }
  }

  define bind_var_file() {
    file { "$bind::var_dir/$name":
      mode => 644, owner => $binduser, group => $binduser,
      source => [ "puppet:///modules/bind/$name" ],
      notify => Service["bind"],
      require => Package[$bind],
    }
  }

  # root zones
  bind_etc_file { "named.root.hints": }
  bind_var_file { "named.root": }

  # rfc1912.zones
  bind_etc_file { "named.rfc1912.zones": }
  bind_var_file { "localdomain.zone": }
  bind_var_file { "localhost.zone": }
  bind_var_file { "named.broadcast": }
  bind_var_file { "named.ip6.local": }
  bind_var_file { "named.local": }
  bind_var_file { "named.zero": }

}

