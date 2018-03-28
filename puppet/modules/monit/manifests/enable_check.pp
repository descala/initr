define monit::enable_check() {
  case $name {
    "" : {}
    default: {
      file { "$monit_d/enabled/$name":
        ensure => "$monit_d/available/$name",
        notify => Service["monit"],
      }
    }
  }
}

