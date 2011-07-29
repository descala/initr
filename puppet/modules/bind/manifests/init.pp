class bind {
  $osavn = "$lsbdistid$lsbdistrelease_class"
  case $operatingsystem {
    Debian,Ubuntu: {
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
      source => "puppet:///modules/bind/empty",
      mode => 770;
    "$var_dir/puppet_zones.conf":
      owner => root,
      group => $binduser,
      mode => 644,
      notify => Service["bind"],
      require => Package[$bind],
      content => template("bind/puppet_zones.conf.erb");
  }

  if array_includes($classes,"nagios::nsca_node") {
    file {
      "/usr/local/bin/nagios_check_dig.sh":
        owner => root, group => root, mode => 700,
        content => template("bind/nagios_check_dig.sh.erb");
    }
    cron {
      "check dig all domains":
        command => "/usr/local/bin/nagios_check_dig.sh &> /dev/null",
        user => root,
        minute => "*/15",
        ensure => present;
    }
  }

  
  create_resources(bind::zoneconf, $bind_masterzones)

  define zoneconf($zone,$ttl,$serial) {

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
  
}

# debian specific

class bind::debian {

  file {
    "$bind::var_dir":
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
