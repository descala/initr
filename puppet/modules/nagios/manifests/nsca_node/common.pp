class nagios::nsca_node::common {

  include common::build_essential
  include nagios::nsca

  # freshness_threshold is 950 in 'passive-host' template
  @@nagios_host { $fqdn:
    use => "passive-host",
    contact_groups => $nagios_contact_groups,
    notify => Service["nagios"],
    tag => $nagios_server
  }

  nagios::service { "uptime": }
  create_resources(nagios::check, $nagios_checks)

  package {
    $libmcrypt:
      ensure => present;
  }

  file {
    "/usr/local/bin/nsca_wrapper":
      mode => 744,
      content => template("nagios/nsca_wrapper.erb");
    "/usr/local/bin/nsca_send":
      mode => 740,
      content => template("nagios/nsca_send.erb");
    "/usr/local/nsca/bin/send":
      ensure => absent; # file above replaces this
  }

}

