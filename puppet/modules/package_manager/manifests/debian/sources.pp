class package_manager::debian::sources {

  file {
    "/etc/apt/sources.list":
      content => template("package_manager/sources.list.erb"),
      notify => Exec["apt-get update"];
    "/etc/apt/sources.list.d/security.sources.list":
      content => template("package_manager/security.sources.list.erb"),
      notify => Exec["apt-get update"];
  }

}
