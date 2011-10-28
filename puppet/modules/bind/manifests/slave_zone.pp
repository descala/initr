define bind::slave_zone($masters) {

  # masters example: { "0200a8144122" => { "ip" => "1.2.3.4" } }

  if array_includes($classes,"nagios::nsca_node") {
    nagios::service {
      "check_dig_$name":
        checkfreshness => "1",
        freshness => "1800",
        ensure => present,
        notifications_enabled => "0";
    }
  }

}

