class nagios::nsca::redhat {
  file {
    "/usr/local/src/install_nsca.sh":
      mode => '0744',
      source => "puppet:///modules/nagios/install_nsca.sh";
  }
  exec {
    "/usr/local/src/install_nsca.sh":
      require => [ File["/usr/local/src/install_nsca.sh"], Package["gcc"] ],
      unless => "[ -f /usr/local/nsca/bin/send_nsca ]";
  }
}

