class package_manager::debian {

  include common::apt

  case $lsbdistcodename {
    "lenny":   { include package_manager::debian::lenny   }
    "squeeze": { include package_manager::debian::squeeze }
    "wheezy":  { include package_manager::debian::wheezy  }
    "n/a": {
      case $lsbmajdistrelease {
        "5": { include package_manager::debian::lenny   }
        "6": { include package_manager::debian::squeeze }
        "7": { include package_manager::debian::wheezy  }
        default: {}
      }
    }
    default: {}
  }

}

