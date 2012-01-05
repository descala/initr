class package_manager::debian::common {

  include package_manager::debian::sources

  if $package_manager::security_updates == "1" {
    include package_manager::debian::automatic_security_updates
  }

}
