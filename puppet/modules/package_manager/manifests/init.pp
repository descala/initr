class package_manager($security_updates) {

  case $operatingsystem {
    "Debian": { include package_manager::debian }
    "Ubuntu": { include package_manager::ubuntu }
    default: {}
  }

}
