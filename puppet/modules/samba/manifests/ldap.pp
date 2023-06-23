class samba::ldap inherits ::ldap {
  File[$::ldap_conf_file] {
    source => undef,
    content => template("samba/slapd.conf.erb")
  }
}

