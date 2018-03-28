# Squid server
#
class squid {
  include common::squid
  $squid_version = $operatingsystem  ? {
    Fedora => "2.5",
    Debian => "2.7", #TODO: Debian has squid3 in stable repository
    default => "2.6"
  }
  file {
    "/etc/squid/squid.conf":
      mode => '0640',
      group => $squid_user,
      content => template("squid/squid.conf.erb"),
      notify => Service["squid"],
      require => Package["squid"];
  }
}
