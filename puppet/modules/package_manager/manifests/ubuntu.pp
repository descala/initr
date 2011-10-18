class package_manager::ubuntu {

  case $lsbdistcodename {
    #TODO
    default: {}
  }
  exec {
    "apt-get update":
      refreshonly => true;
  }
  file {
    "/etc/apt/preferences":
      # TODO
      notify => Exec["apt-get update"];
    "/etc/apt/sources.list":
      content => template("package_manager/sources.list.erb"),
      notify => Exec["apt-get update"];
    "/etc/apt/sources.list.d/security.sources.list":
      content => template("package_manager/security.sources.list.erb"),
      notify => Exec["apt-get update"];
  }

}
