class package_manager::debian::common {
  if $package_manager::security_updates == "1" { include package_manager::debian::automatic_security_updates }
}
