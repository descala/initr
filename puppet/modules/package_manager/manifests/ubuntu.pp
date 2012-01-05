class package_manager::ubuntu {

  include common::apt

#  case $lsbdistcodename {
#    #TODO
#    default: {}
#  }

  file {
    "/etc/apt/preferences":
      #TODO
      notify => Exec["apt-get update"];
    "/etc/apt/sources.list":
      #TODO content => template("package_manager/sources.list.erb"),
      notify => Exec["apt-get update"];
    "/etc/apt/sources.list.d/security.sources.list":
      #TODO content => template("package_manager/security.sources.list.erb"),
      notify => Exec["apt-get update"];
  }

}
