class wpkg::firefox4 inherits wpkg::firefox {

  wpkg::download {
    "firefox4":
      to => "firefox",
      url => "http://download.mozilla.org/?product=firefox-4.0.1&os=win&lang=ca",
      creates => "Firefox Setup 4.0.1.exe";
  }

}

