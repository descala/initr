class common::apache::munin {

  case $lsbdistid {
    "Debian","Ubuntu": {
      common::apache::enmod { ["status.load","status.conf"]: }
      package { "liblwp-useragent-determined-perl":
        ensure => installed,
      }
    }
    default: {
      file { "/etc/httpd/conf.d/status.conf":
        source => "puppet:///modules/common/apache/status.conf",
        notify => Exec["apache reload"],
      }
    }
  }
}


