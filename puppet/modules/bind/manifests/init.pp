class bind {

  $osavn = "$lsbdistid$lsbdistrelease_class"

  case $osavn {
    "MandrivaLinux2006_0": { $bind_base_dir = "/var/lib/named" }
    default: { $bind_base_dir = "" }
  }

  $etc_dir = "$bind_base_dir/etc"
  $var_dir = "$bind_base_dir/var/named"

  service { "named":
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
      group => named,
      mode => 750;
    ["$var_dir/master", "$var_dir/slave", "$var_dir/data"]:
      ensure => directory,
      owner => named,
      group => named,
      require => File["$var_dir"],
      mode => 770;
    "$var_dir/zones.conf":
      # no matxacar-lo si ja existeix
      replace => no,
      mode => 644,
      owner => named,
      group => named,
      source => [ "puppet:///dist/specific/$fqdn/bind-zones.conf", "puppet:///bind/zones.conf" ],
      notify => Service["bind"],
      require => Package[$bind];
    "$etc_dir/named.conf":
      mode => 644,
      owner => root,
      group => root,
      source => [ "puppet:///dist/specific/$fqdn/bind-named.conf", "puppet:///bind/named.conf" ],
      notify => Service["bind"],
      require => Package[$bind];
    "$var_dir/puppet_zones.conf":
      replace => no,
      mode => 644,
      owner => named,
      group => named,
      content => "",
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
      mode => 644, owner => named, group => named,
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

  define zone {
    file { "$bind::var_dir/master/$name.zone":
      owner => named,
      group => named,
      mode => 640,
      source => "puppet:///dist/specific/$fqdn/$name.zone",
      notify => Exec["generate_bind_zones.conf"],
      require => [Package[$bind],File["$bind::var_dir/master"]],
    }
  }
  
  define masterzone ( $serial, $wwwip, $mxip, $mailip="mxip" ) {
    $mail_ip = $mailip ? {
      "mxip" => $mxip,
      default => $mailip
    }
    file { "$bind::var_dir/master/$name.zone":
      owner => named,
      group => named,
      mode => 640,
      content => template("bind/masterdomain.zone.erb"),
      notify => Exec["generate_bind_zones.conf"],
      require => [Package[$bind],File["$bind::var_dir/master"]],
    }
  }

  define nszone ( $serial, $wwwip, $mxip, $nsip ) {
    file { "$bind::var_dir/master/$name.zone":
      owner => named,
      group => named,
      mode => 640,
      content => template("bind/nsdomain.zone.erb"),
      notify => Exec["generate_bind_zones.conf"],
      require => [Package[$bind],File["$bind::var_dir/master"]],
    }
  }

  define slavezone ( $masters ) {
  }

  exec {
    "generate_bind_zones.conf":
      refreshonly => true,
      notify => Service["bind"],
      command => "/usr/local/sbin/generate_bind_zones.conf.sh > $var_dir/puppet_zones.conf";
  }

  file {
    "/usr/local/sbin/generate_bind_zones.conf.sh":
      mode => 700,
      owner => root,
      group => root,
      source => "puppet:///bind/generate_bind_zones.conf.sh";
  }

}
