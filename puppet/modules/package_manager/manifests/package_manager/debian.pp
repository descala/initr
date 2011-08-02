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

