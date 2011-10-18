class package_manager($security_updates = "1") {

  case $operatingsystem {
    "Debian": { include package_manager::debian }
    "Ubuntu": { include package_manager::ubuntu }
    default: {}
  }

}
