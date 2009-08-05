# From http://www.mozilla.com/en-US/firefox/all.html

class wpkg::firefox {

  file {
    "$base/software/firefox":
      ensure => directory;
  }

  download {
    "firefox":
      url => "http://download.mozilla.org/?product=firefox-3.5.2&os=win&lang=ca",
      creates => "Firefox Setup 3.5.2.exe";
  }

}
