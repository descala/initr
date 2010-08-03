import "*.pp"
class package_manager {

  case $operatingsystem {
    "Debian": { include package_manager::debian }
    default: {}
  }

}
