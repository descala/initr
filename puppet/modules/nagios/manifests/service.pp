define nagios::service( $checkfreshness="1", $freshness="1800", $ensure="present", $notifications_enabled="1") {
  @@nagios_service { "${fqdn}_$name":
    use => "passive_service",
    host_name => $fqdn,
    check_freshness => $checkfreshness,
    freshness_threshold => $freshness,
    check_command => "check_stale!1!'This service is stale'",
    notify => Service["nagios"],
    ensure => $ensure,
    notifications_enabled => $notifications_enabled,
    service_description => $name,
    contact_groups => $nagios_contact_groups,
    tag => $nagios_server
  }
}

