class common::apache::passenger {

  # this class assumes that you installed passenger and rails
  # from gems or your distro package manager
  common::apache::enmod { ["passenger.load","passenger.conf"]: }

}

