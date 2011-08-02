class common::apache::munin {

  case $lsbdistid {
    "Debian","Ubuntu": {
      apache::enmod { ["status.load","status.conf"]: }
      package { "liblwp-useragent-determined-perl":
        ensure => installed,
      }
    }
    default: {
      file { "/etc/httpd/conf.d/status.conf":
        source => "puppet:///modules/common/apache/status.conf",
        notify => Service[$httpd_service]
      }
    }
  }
}


