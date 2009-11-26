class bind {
  case $operatingsystem {
    Debian: {
      include bind_debian
    }
    default: {
      include bind_redhat
    }
  }
}

class bind_debian {

  package {
    $bind:
      ensure => installed;
  }

  service {
    $bindservice:
      ensure => running,
      enable => true,
      hasrestart => true,
      hasstatus => true,
      require => Package[$bind],
      alias => bind;
  }

  file {
    "/etc/bind":
      owner => $binduser,
      group => $binduser,
      mode => 770,
      require => Package[$bind],
      ensure => directory;
    "/etc/bind/puppet_zones.conf":
      owner => root,
      group => $binduser,
      mode => 644,
      notify => Service["bind"],
      content => template("bind/named.conf.local.erb");
    "/etc/bind/puppet_zones":
      owner => $binduser,
      group => $binduser,
      mode => 770,
      require => Package[$bind],
      source => "puppet:///bind/empty",
      ignore => ".gitignore",
      purge => true,
      recurse => true,
      force => true;
  }

  append_if_no_such_line { puppet_zones_include:
    file => "/etc/bind/named.conf.local",
    line => "include \"/etc/bind/puppet_zones.conf\"; // line added by puppet",
    require => Package[$bind],
    notify => Service["bind"],
  }


  masterzone { $bind_masterzones: }

  define masterzone($zone) {
    file {
      "/etc/bind/puppet_zones/$name.zone":
        owner => $binduser,
        group => $binduser,
        mode => 640,
        content => template("bind/masterzone.erb"),
        require => [Package[$bind],File["/etc/bind/puppet_zones"]],
        notify => Service[$bind];
    }
  }

}

class bind_redhat {

  $osavn = "$lsbdistid$lsbdistrelease_class"

  $bind_base_dir = $osavn ? {
    "MandrivaLinux2006_0" => "/var/lib/named",
    default => ""
  }

  $etc_dir = "$bind_base_dir/etc"
  $var_dir = "$bind_base_dir/var/named"

  service { $bindservice:
    ensure => running,
    enable => true,
    hasrestart => true,
    require => Package[$bind],
    alias => bind,
  }

  package { $bind:
    ensure => installed,
  }

  file {
    "$var_dir":
      ensure => directory,
      owner => root,
      group => $binduser,
      mode => 750;
    "$var_dir/puppet_zones":
      owner => $binduser,
      group => $binduser,
      require => File["$var_dir"],
      purge => true,
      force => true,
      recurse => true,
      ignore => ".gitignore",
      source => "puppet:///bind/empty",
      mode => 770;
    "$etc_dir/named.conf":
      mode => 644,
      owner => root,
      group => root,
      source => [ "puppet:///dist/specific/$fqdn/bind-named.conf", "puppet:///bind/named.conf" ],
      notify => Service["bind"],
      require => Package[$bind];
    "$var_dir/puppet_zones.conf":
      mode => 644,
      owner => $binduser,
      group => $binduser,
      content => template("bind/puppet_zones.conf.erb"),
      notify => Service["bind"],
      require => Package[$bind];
    "$var_dir/zones.conf":
      # no matxacar-lo si ja existeix
      replace => no,
      mode => 644,
      owner => named,
      group => named,
      source => [ "puppet:///dist/specific/$fqdn/bind-zones.conf", "puppet:///bind/zones.conf" ],
      notify => Service["bind"],
      require => Package[$bind];
  }

  define bind_etc_file() {
    file { "$etc_dir/$name":
      mode => 644, owner => root, group => root,
      source => [ "puppet:///bind/$name" ],
      notify => Service["bind"],
      require => Package[$bind],
    }
  }

  define bind_var_file() {
    file { "$var_dir/$name":
      mode => 644, owner => $binduser, group => $binduser,
      source => [ "puppet:///bind/$name" ],
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

  masterzone { $bind_masterzones: }
  
  define masterzone($zone) {
    file { "$var_dir/puppet_zones/$name.zone":
      owner => $binduser,
      group => $binduser,
      mode => 640,
      content => template("bind/masterzone.erb"),
      require => [Package[$bind],File["$var_dir/puppet_zones"]],
    }
  }

}
