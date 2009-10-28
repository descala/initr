# From http://www.mozillamessaging.com/en-US/thunderbird/all.html

# Class name must match a package id in an XML in files/packages

class wpkg::thunderbird {

  file {
    "$wpkg_base/software/thunderbird":
      ensure => directory;
  }

  download {
    "thunderbird":
      url => "http://download.mozilla.org/?product=thunderbird-2.0.0.23&os=win&lang=ca",
      creates => "Thunderbird Setup 2.0.0.23.exe";
  }

}
