class sshkeys {

  # export ssh host key
  # tags are given from initr (plusignment doesn't work http://projects.reductivelabs.com/issues/2825)
  @@sshkey { $fqdn:
    ensure => present,
    key => $sshrsakey,
    type => "rsa",
    alias => $alias_for_sshkey,
    tag => $tags_for_sshkey,
  }

}
