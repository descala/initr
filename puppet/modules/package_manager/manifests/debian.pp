class package_manager::debian {

  case $lsbdistcodename {
    "lenny":   { include package_manager::debian::lenny   }
    "squeeze": { include package_manager::debian::squeeze }
    "n/a": {
      case $lsbdistrelease {
        /^5/: { include package_manager::debian::lenny   }
        /^6/: { include package_manager::debian::squeeze }
        default: {}
      }
    }
    default: {}
  }
  exec {
    "apt-get update":
      refreshonly => true;
  }
  file {
    "/etc/apt/sources.list":
      content => template("package_manager/sources.list.erb"),
      notify => Exec["apt-get update"];
    "/etc/apt/sources.list.d/security.sources.list":
      content => template("package_manager/security.sources.list.erb"),
      notify => Exec["apt-get update"];
  }

}

class package_manager::debian::lenny {

  file {
    "/etc/apt/preferences":
      content => template("package_manager/preferences_lenny.erb"),
      notify => Exec["apt-get update"];
  }

  if $security_updates == "1" { include package_manager::debian::automatic_security_updates }

}

class package_manager::debian::squeeze inherits package_manager::debian::lenny {

  File["/etc/apt/preferences"] { content => template("package_manager/preferences_squeeze.erb") }

}

class package_manager::debian::automatic_security_updates {
  file {
    "/etc/cron-apt/action.d/5-install":
      source => "puppet:///modules/package_manager/cron-apt_5-install",
      require => Package["cron-apt"];
  }
  package {
    "cron-apt":
      ensure => installed,
      require => [File["/etc/apt/sources.list"],File["/etc/apt/preferences"]];
  }
}
