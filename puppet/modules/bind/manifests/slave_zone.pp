define bind::slave_zone {

  if array_includes($classes,'nagios::nsca_node') {
    nagios::service {
      "check_dig_${name}":
        ensure                => present,
        checkfreshness        => '1',
        freshness             => '1800',
        notifications_enabled => '0';
    }
  }

}
