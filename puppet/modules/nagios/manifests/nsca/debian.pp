class nagios::nsca::debian {
  package {
    "nsca":
      ensure => present;
  }
}

