class nagios::server::common {

  include common::apache
  include nagios::nsca

  file {
    "/etc/nagios/":
      ensure => directory,
      mode => '0755',
      owner => nagios,
      group => $nagios_group;
    # file to manually enter conf
    "/etc/nagios/nagios_extra.cfg":
      owner => nagios,
      group => $nagios_group,
      mode => '0644',
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
      mode => '0644',
      ensure => file,
      replace => false,
      require => File["/etc/nagios"],
      notify => Service["nagios"];
    "/etc/nagios/templates":
      owner => nagios,
      group => $nagios_group,
      mode => '0640',
      recurse => true,
      source => "puppet:///modules/nagios/templates",
      notify => Service["nagios"];
    "/etc/nagios/templates/passive.cfg":
      owner => nagios,
      group => $nagios_group,
      mode => '0640',
      recurse => true,
      content => template("nagios/passive.cfg.erb"),
      notify => Service["nagios"],
      require => File["/etc/nagios/templates"];
    "/etc/nagios/templates/templates.cfg":
      owner => nagios,
      group => $nagios_group,
      mode => '0640',
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

  Nagios_host <<| tag == $nagios_address |>>

  Nagios_service <<| tag == $nagios_address |>>

  create_resources(nagios::server::common::contact, $nagios_contacts)
  define contact($nagiosalias,$email) {
    nagios_contact { $name:
      alias => $nagiosalias,
      email => $email,
      use => "generic-contact",
      notify => Service["nagios"],
      require => File["/etc/nagios/nagios_contact.cfg"],
    }
  }
  create_resources(nagios::server::common::contactgroup, $nagios_contactgroups)
  define contactgroup($members,$nagiosalias) {
    nagios_contactgroup { $name:
      members => $members,
      alias => $nagiosalias,
      notify => Service["nagios"],
      require => File["/etc/nagios/nagios_contactgroup.cfg"],
    }
  }
  create_resources(nagios::server::common::hostgroup, $nagios_hostgroups)
  define hostgroup($members,$nagiosalias) {
    nagios_hostgroup { $name:
      members => $members,
      alias => $nagiosalias,
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

