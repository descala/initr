class package_manager::debian {

  include common::apt

  case $lsbdistcodename {
    "lenny":   { include package_manager::debian::lenny   }
    "squeeze": { include package_manager::debian::squeeze }
    "n/a": {
      case $lsbmajdistrelease {
        "5": { include package_manager::debian::lenny   }
        "6": { include package_manager::debian::squeeze }
        default: {}
      }
    }
    default: {}
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

