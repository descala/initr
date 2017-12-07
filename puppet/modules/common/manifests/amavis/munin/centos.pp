class common::amavis::munin::centos inherits common::amavis::munin::common {
  file { "/usr/sbin/logtail":
    mode => "755",
    source => "puppet:///modules/common/amavis/logtail",
    owner => "root",
    group => "root",
    replace => false,
  }
}

