# From http://www.mozilla.com/en-US/firefox/all.html

# Class name must match a package id in an XML in files/packages

class wpkg::firefox {

  file {
    "$wpkg_base/software/firefox":
      ensure => directory;
  }

}

class wpkg::firefox3 inherits firefox {

  download {
    "firefox":
      to => "firefox",
      url => "http://download.mozilla.org/?product=firefox-3.6.8&os=win&lang=ca",
      creates => "Firefox Setup 3.6.8.exe";
  }

}

class wpkg::firefox4 inherits firefox {

  download {
    "firefox4":
      to => "firefox",
      url => "http://download.mozilla.org/?product=firefox-4.0.1&os=win&lang=ca",
      creates => "Firefox Setup 4.0.1.exe";
  }

}
