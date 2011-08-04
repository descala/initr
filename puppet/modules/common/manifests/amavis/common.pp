class common::amavis::common {
  package {
    "amavisd-new":
      ensure => installed;
  }
  if array_includes($classes,"munin") {
    include common::amavis::munin
  }
}

