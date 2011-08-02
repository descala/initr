class common::sshkeys {

  # export ssh host key
  # tags are given from initr (plusignment doesn't work http://projects.reductivelabs.com/issues/2825)
  @@sshkey { $fqdn:
    ensure => present,
    key => $sshrsakey,
    type => "rsa",
    host_aliases => $host_alias_for_sshkey,
    tag => $tags_for_sshkey,
  }

}
