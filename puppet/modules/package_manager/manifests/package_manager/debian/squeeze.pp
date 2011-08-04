class package_manager::debian::squeeze inherits package_manager::debian::lenny {

  File["/etc/apt/preferences"] { content => template("package_manager/preferences_squeeze.erb") }

}

