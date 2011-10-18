class package_manager::debian::squeeze inherits package_manager::debian::common {

  file {
    "/etc/apt/preferences":
      content => template("package_manager/preferences_squeeze.erb"),
      notify => Exec["apt-get update"];
  }

}

