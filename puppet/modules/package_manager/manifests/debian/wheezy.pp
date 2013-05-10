class package_manager::debian::wheezy inherits package_manager::debian::common {

  file {
    "/etc/apt/preferences":
      content => template("package_manager/preferences_wheezy.erb"),
      notify => Exec["apt-get update"];
  }

}

