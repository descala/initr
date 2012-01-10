class wpkg::firefox { 

  file {
    "$wpkg_base/software/firefox":
      ensure => directory;
  }

  wpkg::download {
    "firefox":
      to => "firefox",
      url => "http://download.mozilla.org/?product=firefox-9.0.1&os=win&lang=ca",
      creates => "Firefox Setup 9.0.1.exe";
  }

}
