class package_manager::debian::lenny inherits package_manager::debian::common {

  file {
    "/etc/apt/preferences":
      content => template("package_manager/preferences_lenny.erb"),
      notify => Exec["apt-get update"];
  }

}
