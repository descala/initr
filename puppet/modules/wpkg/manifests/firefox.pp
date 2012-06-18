class wpkg::firefox { 

  file {
    "$wpkg_base/software/firefox":
      ensure => directory;
  }

  wpkg::download {
    "firefox":
      to => "firefox",
      url => "http://download.mozilla.org/?product=firefox-13.0.1&os=win&lang=ca",
      creates => "Firefox Setup 13.0.1.exe";
  }

}
