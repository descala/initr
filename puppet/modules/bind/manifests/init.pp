class bind($bind_masterzones={},$nameservers=[],
  $bind_slave_zones={},$bind_slave_servers=[]) {

  $bind = $operatingsystem ? {
    /Debian|Ubuntu/ => bind9,
    default         => bind
  }
  $binduser = $operatingsystem ? {
    /Debian|Ubuntu/ => bind,
    default         => named
  }
  $bindservice = $operatingsystem ? {
    /Debian|Ubuntu/ => bind9,
    default         => named
  }

  $osavn = "$lsbdistid$lsbdistrelease"
  case $operatingsystem {
    Debian,Ubuntu: {
      $etc_dir = '/etc/bind'
      $var_dir = $etc_dir
      include bind::debian
    }
    default: {
      $bind_base_dir = $osavn ? {
        'MandrivaLinux2006.0' => '/var/lib/named',
        default               => ''
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
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
      require    => Package[$bind],
      alias      => bind;
  }

  file {
    "$var_dir/puppet_zones":
      owner   => $binduser,
      group   => $binduser,
      require => [File[$var_dir],Package[$bind]],
      purge   => true,
      force   => true,
      recurse => true,
      ignore  => '.gitignore',
      source  => 'puppet:///modules/bind/empty',
      mode    => '0770';
    "$var_dir/puppet_slave_zones":
      ensure  => directory,
      owner   => $binduser,
      group   => $binduser,
      require => [File[$var_dir],Package[$bind]],
      mode    => '0770';
    "$var_dir/puppet_zones.conf":
      owner   => root,
      group   => $binduser,
      mode    => '0644',
      notify  => Service['bind'],
      require => Package[$bind],
      content => template('bind/puppet_zones.conf.erb');
    "$var_dir/puppet_slave_zones.conf":
      owner   => root,
      group   => $binduser,
      mode    => '0644',
      notify  => Service['bind'],
      require => Package[$bind],
      content => template('bind/puppet_slave_zones.conf.erb');
  }

  if array_includes($classes,'nagios::nsca_node') {
    file {
      '/usr/local/bin/nagios_check_dig.sh':
        owner   => root, group => root, mode => '0700',
        content => template('bind/nagios_check_dig.sh.erb');
    }
    cron {
      'check dig all domains':
        ensure  => present,
        command => '/usr/local/bin/nagios_check_dig.sh > /dev/null 2>&1',
        user    => root,
        minute  => '*/15';
    }
  }

  create_resources(bind::zone, $bind_masterzones)
  bind::slave_zone { hash_values($bind_slave_zones): }
}

