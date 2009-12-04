class bind {
  $osavn = "$lsbdistid$lsbdistrelease_class"
  case $operatingsystem {
    Debian: {
      $etc_dir = "/etc/bind"
      $var_dir = $etc_dir
      include bind::debian
    }
    default: {
      $bind_base_dir = $osavn ? {
        "MandrivaLinux2006_0" => "/var/lib/named",
        default => ""
      }
      $etc_dir = "$bind_base_dir/etc"
      $var_dir = "$bind_base_dir/var/named"
      include bind::redhat
    }
  }

  # common definitions
  
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
    "$var_dir/puppet_zones":
      owner => $binduser,
      group => $binduser,
      require => [File["$var_dir"],Package[$bind]],
      purge => true,
      force => true,
      recurse => true,
      ignore => ".gitignore",
      source => "puppet:///bind/empty",
      mode => 770;
    "$var_dir/puppet_zones.conf":
      owner => root,
      group => $binduser,
      mode => 644,
      notify => Service["bind"],
      require => Package[$bind],
      content => template("bind/puppet_zones.conf.erb");
  }
  
  zoneconf { $bind_masterzones: }

  define zoneconf($zone,$ttl,$serial) {

    # if nagios server is available then export resource
    # TODO: better way to know if node includes Nagios class?
    if $nagios_proxytunnel == "0" or $nagios_proxytunnel == "1" {
      nagios::nsca_node::wrapper_check { "check_dig_$name":
        command => "/usr/local/nagios/libexec/check_dig -T NS -l $name  -H 127.0.0.1",
      }
    }

    file {
      "$var_dir/puppet_zones/$name.zone":
        owner => $binduser,
        group => $binduser,
        mode => 640,
        content => template("bind/zone.erb"),
        require => [Package[$bind],File["$var_dir/puppet_zones"]],
        notify => Service[$bind];
    }
  }
  
}

# debian specific

class bind::debian {

  file {
    "$var_dir":
      owner => $binduser,
      group => $binduser,
      mode => 770,
      require => Package[$bind],
      ensure => directory;
  }

  append_if_no_such_line { puppet_zones_include:
    file => "/etc/bind/named.conf.local",
    line => "include \"/etc/bind/puppet_zones.conf\"; // line added by puppet",
    require => Package[$bind],
    notify => Service["bind"],
  }

}

# redhat specific

class bind::redhat {


  file {
    "$var_dir":
      ensure => directory,
      owner => root,
      group => $binduser,
      mode => 750;
    "$etc_dir/named.conf":
      mode => 644,
      owner => root,
      group => root,
      source => [ "puppet:///dist/specific/$fqdn/bind-named.conf", "puppet:///bind/named.conf" ],
      notify => Service["bind"],
      require => Package[$bind];
    "$var_dir/zones.conf":
      # do not overwrite file, let it be manualy modified
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

}
