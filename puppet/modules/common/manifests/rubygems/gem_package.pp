define common::gem_package($ensure=installed) {
  case $rubygems_version {
    "": {
      warning("Rubygems not installed: can not manage '$name' package. rubygems_version='$rubygems_version'")
      # dummy definition, allows requires
      # it always fails as package does not exist
      # eventualy rubygems will be installed and use the gem provider
      package { "my-dummy-rubygems-$name":
        ensure => $ensure,
        alias => $name,
      }
    }
    default: {
      package { $name:
        provider => gem,
        ensure => $ensure,
      }
    }
  }
}
