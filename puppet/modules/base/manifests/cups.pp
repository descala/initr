class cups {
  package { "cups":
    ensure => "installed",
  }

  service { "cups":
    ensure => "running",
    enable => true,
    hasrestart => true,
    hasstatus => true,
    require => Package["cups"],
  }

  append_if_no_such_line { mimetypes:
    file => "/etc/cups/mime.types",
    line => "application/octet-stream",
    require => Package["cups"],
    notify => Service["cups"],
  }

  append_if_no_such_line { mimeconvs:
    file => "/etc/cups/mime.convs",
    line => "application/octet-stream        application/vnd.cups-raw        0       -",
    require => Package["cups"],
    notify => Service["cups"],
  }

  if $printers {
    file { "/etc/cups/printers.conf":
      mode => 600,
      group => lp,
      content => $printers,
      require => Package["cups"],
      notify => Service["cups"],
    }
  }
}
