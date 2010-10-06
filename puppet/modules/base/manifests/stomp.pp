class stomp {

  case $operatingsystem {
    Debian: {
      package {
        "libstomp-ruby":
          ensure => installed,
          alias => "stomp";
      }
    }
    default: {
      include rubygems
      gem_package {
        "stomp":
          ensure => "1.1.6";
      }
    }
  }

}
