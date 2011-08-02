class nagios::check_router {

  @@nagios_host { "${fqdn}_router":
    use => "generic-switch",
    contact_groups => $nagios_contact_groups,
    notify => Service["nagios"],
    tag => $nagios_server,
    address => "${fqdn}.${ddns_domain}",
  }

}

