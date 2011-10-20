class common::apache::passenger {

  if $operatingsystem == "Debian" {
    # this class assumes that you installed passenger and rails
    # from gems or your distro package manager
    common::apache::enmod { ["passenger.load","passenger.conf"]: }
  } else {
    #TODO
  }

}

