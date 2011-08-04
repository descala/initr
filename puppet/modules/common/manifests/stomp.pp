class common::stomp {

  include common::rubygems
  common::rubygems::gem_package {
    "stomp":
      ensure => "1.1.6";
  }

}
