class sshkeys {

  # export ssh host key
  # tags are given from initr, see http://projects.reductivelabs.com/issues/2825
  @@sshkey { $fqdn:
    ensure => present,
    alias => $alias_for_sshkey,
    key => $sshrsakey,
    type => "rsa",
    tag => $tags_for_sshkey,
  }

}
