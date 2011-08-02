class common::apache::ssl inherits common::apache {

  if $ssl_module != "" {
    package { $ssl_module:
      ensure => installed,
    }
  }

  # generates self-signed certs
  case $lsbdistid {
    "Debian","Ubuntu": {
      package { "ssl-cert":
        ensure => installed,
      }
    }
  }

  #TODO: enmod ssl ?

}

