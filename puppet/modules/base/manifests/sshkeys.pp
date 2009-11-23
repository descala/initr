class sshkeys {

  if $alias_for_sshkey {
    $alias = $alias_for_sshkey
  } else {
    $alias = ""
  }

  # export ssh host key
  # tags and alias are given from initr, see http://projects.reductivelabs.com/issues/2825
  @@sshkey { $fqdn:
    ensure => present,
    alias => $alias,
    key => $sshrsakey,
    type => "rsa",
    tag => $tags_for_sshkey,
  }

}
