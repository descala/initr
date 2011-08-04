class package_manager::debian::lenny {

  file {
    "/etc/apt/preferences":
      content => template("package_manager/preferences_lenny.erb"),
      notify => Exec["apt-get update"];
  }

  if $security_updates == "1" { include package_manager::debian::automatic_security_updates }

}

