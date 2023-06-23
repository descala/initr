class gnulinux::debian7 inherits gnulinux::debian {
  if $is_virtual != "true" {
    package {
      "firmware-linux-nonfree":
        ensure => present;
    }
  }
}
