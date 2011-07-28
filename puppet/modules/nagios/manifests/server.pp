class nagios::server {

  case $operatingsystem {
    Debian: {
      case $lsbdistcodename {
        dapper: { include nagios::server::redhat }
        default: { include nagios::server::debian }
      }
    }
    default: { include nagios::server::redhat }
  }

}

class nagios::server::common {

  include apache
  include nagios::nsca

  file {
    "/etc/nagios/":
      ensure => directory,
      mode => 755,
      owner => nagios,
      group => $nagios_group;
    # file to manually enter conf
    "/etc/nagios/nagios_extra.cfg":
      owner => nagios,
      group => $nagios_group,
      mode => 0644,
      ensure => file,
      replace => false,
      require => File["/etc/nagios"];
    [ "/etc/nagios/nagios_contact.cfg",
      "/etc/nagios/nagios_contactgroup.cfg",
      "/etc/nagios/nagios_host.cfg",
      "/etc/nagios/nagios_service.cfg",
      "/etc/nagios/nagios_hostgroup.cfg",
      "/etc/nagios/nagios_hostescalation.cfg",
      "/etc/nagios/nagios_serviceescalation.cfg" ]:
      owner => nagios,
      group => $nagios_group,
      mode => 0644,
      ensure => file,
      replace => false,
      require => File["/etc/nagios"],
      notify => Service["nagios"];
    "/etc/nagios/templates":
      owner => nagios,
      group => $nagios_group,
      mode => 640,
      recurse => true,
      source => "puppet:///modules/nagios/templates",
      notify => Service["nagios"];
    "/etc/nagios/templates/passive.cfg":
      owner => nagios,
      group => $nagios_group,
      mode => 640,
      recurse => true,
      content => template("nagios/passive.cfg.erb"),
      notify => Service["nagios"],
      require => File["/etc/nagios/templates"];
    "/etc/nagios/templates/templates.cfg":
      owner => nagios,
      group => $nagios_group,
      mode => 640,
      recurse => true,
      content => template("nagios/templates.cfg.erb"),
      notify => Service["nagios"],
      require => File["/etc/nagios/templates"];
  }
  resources { nagios_host: purge => true }
  resources { nagios_service: purge => true }
  resources { nagios_contact: purge => true }
  resources { nagios_contactgroup: purge => true }
  resources { nagios_hostgroup: purge => true }
  resources { nagios_hostescalation: purge => true }
  resources { nagios_serviceescalation: purge => true }

  Nagios_host <<| tag == $nagios_address |>> {
    schedule => daily,
  }
  Nagios_service <<| tag == $nagios_address |>> {
    schedule => daily,
  }
  create_resources(nagios::server::common::contact, $nagios_contacts)
  define contact($alias,$email) {
    nagios_contact { $name:
      alias => $alias,
      email => $email,
      use => "generic-contact",
      notify => Service["nagios"],
      require => File["/etc/nagios/nagios_contact.cfg"],
    }
  }
  create_resources(nagios::server::common::contactgroup, $nagios_contactgroups)
  define contactgroup($members,$alias) {
    nagios_contactgroup { $name:
      members => $members,
      alias => $alias,
      notify => Service["nagios"],
      require => File["/etc/nagios/nagios_contactgroup.cfg"],
    }
  }
  create_resources(nagios::server::common::hostgroup, $nagios_hostgroups)
  define hostgroup($members,$alias) {
    nagios_hostgroup { $name:
      members => $members,
      alias => $alias,
      notify => Service["nagios"],
      require => File["/etc/nagios/nagios_hostgroup.cfg"],
    }
  }
  create_resources(nagios::server::common::hostescalation, $nagios_hostescalations)
  define hostescalation($last_notification,$contact_groups,$notification_interval,$first_notification,$hostgroup_name) {
    nagios_hostescalation { $name:
      last_notification => $last_notification,
      contact_groups => $contact_groups,
      notification_interval => $notification_interval,
      first_notification => $first_notification,
      hostgroup_name => $hostgroup_name,
      notify => Service["nagios"],
      require => File["/etc/nagios/nagios_hostescalation.cfg"],
    }
  }
  create_resources(nagios::server::common::serviceescalation, $nagios_serviceescalations)
  define serviceescalation($last_notification,$contact_groups,$notification_interval,$service_description,$first_notification,$hostgroup_name) {
    nagios_serviceescalation { $name:
      last_notification => $last_notification,
      contact_groups => $contact_groups,
      notification_interval => $notification_interval,
      service_description => $service_description,
      first_notification => $first_notification,
      hostgroup_name => $hostgroup_name,
      notify => Service["nagios"],
      require => File["/etc/nagios/nagios_serviceescalation.cfg"],
    }
  }
  # freshness_threshold is 950 in 'passive-host' template
#  nagios_host { $fqdn:
#    alias => $fqdn,
#    use => "linux-server",
##TODO    contact_groups => $nagios_contact_groups,
#    notify => Service["nagios"],
#    schedule => daily,
#  }
}

class nagios::server::debian inherits nagios::server::common {

  package {
    "nagios3":
      ensure => installed,
      alias => nagios;
  }
  service {
    "nagios3":
      enable => true,
      ensure => running,
      hasstatus => true,
      hasrestart => true,
      alias => nagios;
    "nsca":
      enable => true,
      ensure => running,
      hasstatus => false,
      hasrestart => true;
  }
  file {
    "/etc/nagios3/htpasswd.users":
      content => template("nagios/htpasswd.users.erb"),
      owner => root,
      group => $httpd_user,
      mode => 0640,
      require => Package["nagios3"];
    # needed for nagios external command (/usr/share/doc/nagios3/README.Debian)
    "/var/lib/nagios3":
      owner => nagios,
      group => nagios,
      mode => 0751,
      require => Package["nagios3"];
    # needed for nagios external command (/usr/share/doc/nagios3/README.Debian)
    "/var/lib/nagios3/rw":
      owner => nagios,
      group => www-data,
      mode => 2710,
      require => Package["nagios3"];
    "/etc/nagios3/nagios.cfg":
      content => template("nagios/nagios.cfg.erb"),
      notify => Service["nagios3"],
      require => Package["nagios3"];
    # puppet needs nagios conf in default dir to purge it (architectural limitation)
    "/etc/nagios3/conf.d":
      ensure => "/etc/nagios",
      backup => false,
      force => true,
      require => File["/etc/nagios"];
    "/etc/nagios3/commands.cfg":
      content => template("nagios/commands.cfg.erb"),
      require => Package["nagios3"],
      notify => Service["nagios"];
    "/etc/nsca.cfg":
      owner => nagios,
      group => $nagios_group,
      mode => 640,
      content => template("nagios/nsca.cfg.erb"),
      require => [Package["nsca"], Package["nagios"]],
      notify => Service["nsca"];
    "/etc/apache2/conf.d/nagios3.conf":
      source => "puppet:///modules/nagios/apache.conf";
    # Replace init.d script to check config before restart nagios daemon
    "/etc/init.d/nagios3":
      owner => root,
      group => root,
      mode => 755,
      source => "puppet:///modules/nagios/nagios_init_script_debian";
  }
}

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
      mode => 744,
      source => "puppet:///modules/nagios/install_nagios.sh";
    "/usr/local/nagios/etc/nagios.cfg":
      owner => nagios,
      group => nagcmd,
      mode => 640,
      source => "puppet:///modules/nagios/nagios.cfg",
      notify => Service["nagios"],
      require => [User["nagios"],Exec["/usr/local/src/install_nagios.sh"]];
    "/usr/local/nagios/etc/objects/passive.cfg":
      owner => nagios,
      group => nagcmd,
      mode => 640,
      content => template("nagios/passive.cfg.erb"),
      notify => Service["nagios"],
      require => User["nagios"];
    "$httpd_confdir/nagios.conf":
      owner => root,
      group => root,
      mode => 644,
      source => "puppet:///modules/nagios/nagios_httpd.conf",
      notify => Service[$httpd_service];
    "/usr/local/nagios/etc/htpasswd.users":
      owner => root,
      group => $httpd_user,
      mode => 640,
      content => template("nagios/htpasswd.users.erb"),
      require => Package[$httpd],
      notify => Service[$httpd_service];
    "/etc/init.d/nagios":
      owner => root,
      group => root,
      mode => 755,
      source => "puppet:///modules/nagios/nagios_init_script";
    "/usr/local/nsca/etc/nsca.cfg":
      owner => nagios,
      group => nagcmd,
      mode => 640,
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

