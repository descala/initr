class nagios::server::redhat inherits nagios::server::common {

  package {
    "nagios":
      ensure => absent; # volem nagios 3, instalarem del codi font
  }

  service {
    "nagios":
      ensure => running,
      hasrestart => true,
      hasstatus => true,
      enable => true;
  }

  file {
    "/usr/local/src/install_nagios.sh":
      owner => root,
      group => root,
      mode => '0744',
      source => "puppet:///modules/nagios/install_nagios.sh";
    "/usr/local/nagios/etc/nagios.cfg":
      owner => nagios,
      group => nagcmd,
      mode => '0640',
      source => "puppet:///modules/nagios/nagios.cfg",
      notify => Service["nagios"],
      require => [User["nagios"],Exec["/usr/local/src/install_nagios.sh"]];
    "/usr/local/nagios/etc/objects/passive.cfg":
      owner => nagios,
      group => nagcmd,
      mode => '0640',
      content => template("nagios/passive.cfg.erb"),
      notify => Service["nagios"],
      require => User["nagios"];
    "$httpd_confdir/nagios.conf":
      owner => root,
      group => root,
      mode => '0644',
      source => "puppet:///modules/nagios/nagios_httpd.conf",
      notify => Exec["apache reload"];
    "/usr/local/nagios/etc/htpasswd.users":
      owner => root,
      group => $httpd_user,
      mode => '0640',
      content => template("nagios/htpasswd.users.erb"),
      require => Package[$httpd],
      notify => Exec["apache reload"];
    "/etc/init.d/nagios":
      owner => root,
      group => root,
      mode => '0755',
      source => "puppet:///modules/nagios/nagios_init_script";
    "/usr/local/nsca/etc/nsca.cfg":
      owner => nagios,
      group => nagcmd,
      mode => '0640',
      content => template("nagios/nsca.cfg.erb"),
      require => Exec["/usr/local/src/install_nagios.sh"];
  }

  user { "nagios":
    ensure => present,
    groups => nagcmd,
    require => Group["nagcmd"],
  }

  group { "nagcmd":
    ensure => present,
    notify => Exec["/usr/sbin/usermod -a -G nagcmd apache"],
    require => Package[$httpd],
  }

  exec {
    "/usr/local/src/install_nagios.sh":
      require => [File["/usr/local/src/install_nagios.sh"],Package["gcc"]],
      unless => "[ -f /usr/local/nagios/bin/nagios ]";
    "/usr/sbin/usermod -a -G nagcmd apache":
      refreshonly => true;
    "/usr/local/nsca/bin/nsca -c /usr/local/nsca/etc/nsca.cfg": #TODO: monit hauria de comprovar que aixo corre, no el puppet.
      onlyif => "[ -z \"`ps awx | grep '/usr/local/nsca/bin/nsca' | grep -v grep`\" ]";
  }

}

