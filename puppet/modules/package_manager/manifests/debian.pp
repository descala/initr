class package_manager::debian {

  case $lsbdistcodename {
    "lenny":   { include package_manager::debian::lenny   } # stable
    "squeeze": { include package_manager::debian::squeeze } # testing
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
      content => template("package_manager/preferences.erb"),
      notify => Exec["apt-get update"];
  }

  if $security_updates == "1" { include package_manager::debian::lenny::automatic_security_updates }

}

class package_manager::debian::squeeze {
}

class package_manager::debian::lenny::automatic_security_updates {
  file {
    "/etc/cron-apt/action.d/5-install":
      source => "puppet:///package_manager/cron-apt_5-install";
  }
  package {
    "cron-apt":
      ensure => installed;
  }
}
