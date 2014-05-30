class wpkg::firefox { 

  file {
    "$wpkg_base/software/firefox":
      ensure => directory;
  }

  wpkg::download {
    'firefox':
      to      => 'firefox',
      url     => 'ftp://ftp.mozilla.org/pub/firefox/releases/latest/win32/ca/Firefox%20Setup%2029.0.1.exe',
      creates => 'Firefox Setup 29.0.1.exe';
  }

}
