import "*.pp"
class package_manager {

  case $operatingsystem {
    "Debian": { include package_manager::debian }
    "Ubuntu": { include package_manager::ubuntu }
    default: {}
  }

}
