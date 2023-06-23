class dyndns {

  if array_includes($classes,"nagios::nsca_node") {
    if $skip_nagios_check != "1" {
      include nagios::check_router
    }
  }

  package {
    "ddclient":
      ensure => installed;
  }

  service {
    "ddclient":
      enable => true,
      ensure => running,
      require => Package["ddclient"];
  }

  file {
    "/etc/ddclient.conf":
      owner => $ddclient_user, group => root, mode => '0600',
      content => template("dyndns/ddclient.conf.erb"),
      require => Package["ddclient"],
      notify => Service["ddclient"];
    "/etc/default/ddclient":
      owner => $ddclient_user, group => root, mode => '0600',
      source => "puppet:///modules/dyndns/ddclient",
      require => Package["ddclient"],
      notify => Service["ddclient"];
  }

}

#TODO:
#class dyndns::server {
#
#  package {
#    "bind9utils":
#      ensure => installed;
#  }
#  file {
#    "/etc/bind/keys":
#      ensure => directory,
#      mode => '0755';
#    "/etc/bind/dynamic_zones.conf":
#      content => template("dyndns/dynamic_zones.conf.erb");
#  }
#  exec {
#    "create dnssec key":
#      command => "dnssec-keygen -b 512 -a HMAC-MD5 -v 2 -n HOST localhost",
#      unless => "ls /etc/bind/keys/Klocalhost*",
#      cwd => "/etc/bind/keys",
#      require => [File["/etc/bind/keys"],Package["bind9utils"]],
#      notify => Exec["create key auth"];
#    "create key auth":
#      refreshonly => true,
#      cwd => "/etc/bind/keys/",
#      command => 'secret=`cat K*.private | grep "^Key"|cut -d" " -f2`
#cat << EOF > localhost
#key localhost {
#    algorithm "HMAC-MD5";
#    secret "$secret";
#};
#EOF';
#  }
#  append_if_no_such_line { dynamic_zones_include:
#    file => "/etc/bind/named.conf.local",
#    line => "include \"/etc/bind/dynamic_zones.conf\"; // line added by puppet",
#    require => [Package[$bind],Exec["create key auth"]],
#    notify => Service["bind"],
#  }
#}
