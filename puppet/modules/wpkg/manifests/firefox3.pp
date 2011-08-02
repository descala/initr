class wpkg::firefox3 inherits wpkg::firefox {

  wpkg::download {
    "firefox":
      to => "firefox",
      url => "http://download.mozilla.org/?product=firefox-3.6.17&os=win&lang=ca",
      creates => "Firefox Setup 3.6.17.exe";
  }

}

