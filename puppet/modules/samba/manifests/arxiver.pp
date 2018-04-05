class samba::arxiver {

  exec { "/bin/mkdir -p $samba::smbdir/documents":
    creates => "$samba::smbdir/documents",
    before => File["$samba::smbdir/documents/.ingent"],
  }

  user { "arxiver":
    comment => "Ingent Arxiver",
    ensure => present,
    shell => "/sbin/nologin",
  }

  file {
    "$samba::smbdir/documents/.ingent":
      ensure => directory,
      mode => '0755';
  }

}

