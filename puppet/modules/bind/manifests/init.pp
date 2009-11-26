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
    "/etc/bind/named.conf.local":
      owner => root,
      group => $binduser,
      mode => 644,
      notify => Service["bind"],
      content => template("bind/named.conf.local.erb");
    "/etc/bind/master":
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

  masterzone { $bind_masterzones: }

  define masterzone($zone) {
    file {
      "/etc/bind/master/$name.zone":
        owner => $binduser,
        group => $binduser,
        mode => 640,
        content => template("bind/masterzone.erb"),
        require => [Package[$bind],File["/etc/bind/master"]],
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
    "$var_dir/master":
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
    file { "$var_dir/master/$name.zone":
      owner => $binduser,
      group => $binduser,
      mode => 640,
      content => template("bind/masterdomain.zone.erb"),
      require => [Package[$bind],File["$var_dir/master"]],
    }
  }

}
