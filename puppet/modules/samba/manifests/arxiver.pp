class samba::arxiver {

  exec { "/bin/mkdir -p $::smbdir/documents":
    creates => "$::smbdir/documents",
    before => File["$::smbdir/documents/.ingent"],
  }

  user { "arxiver":
    comment => "Ingent Arxiver",
    ensure => present,
    shell => $nologin,
  }

  file {
    "$::smbdir/documents/.ingent":
      ensure => directory,
      mode => '0755';
  }

}

