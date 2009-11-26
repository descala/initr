class sshkeys {

  $array=[]
  $alias = $alias_for_sshkey ? {
    $array => undef,
    "" => undef,
    default => $alias_for_sshkey,
  }

  # export ssh host key
  # tags and alias are given from initr, see http://projects.reductivelabs.com/issues/2825
  if $alias {
    @@sshkey { $fqdn:
      ensure => present,
      alias => $alias,
      key => $sshrsakey,
      type => "rsa",
      tag => $tags_for_sshkey,
    }
  } else {
    @@sshkey { $fqdn:
      ensure => present,
      key => $sshrsakey,
      type => "rsa",
      tag => $tags_for_sshkey,
    }
  }

}
