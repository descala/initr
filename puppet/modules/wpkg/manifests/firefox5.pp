class wpkg::firefox5 inherits wpkg::firefox {

  wpkg::download {
    "firefox5":
      to => "firefox",
      url => "http://download.mozilla.org/?product=firefox-5.0&os=win&lang=ca",
      creates => "Firefox Setup 5.0.exe";
  }

}
