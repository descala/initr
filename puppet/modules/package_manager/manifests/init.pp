class package_manager($security_updates="0") {

  case $operatingsystem {
    "Debian": { include package_manager::debian }
    "Ubuntu": { include package_manager::ubuntu }
    default: {}
  }

}
