class sshkeys {

  $array=[]
  $alias = $alias_for_sshkey ? {
    $array => "",
    default => $alias_for_sshkey,
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
