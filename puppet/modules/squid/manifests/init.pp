# Squid server
#
class squid {
  include common::squid
  file {
    "/etc/squid/squid.conf":
      mode => '0640',
      group => $squid_user,
      content => template("squid/squid.conf.erb"),
      notify => Service["squid"],
      require => Package["squid"];
  }
}
