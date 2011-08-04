class common::build_essential {

  case $operatingsystem {
    "Debian": {
      package { "build-essential": ensure => installed }
    }
    default: {}
  }

}
