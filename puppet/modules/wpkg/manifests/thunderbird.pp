# From http://www.mozillamessaging.com/en-US/thunderbird/all.html

class wpkg::thunderbird {

  file {
    "$base/software/thunderbird":
      ensure => directory;
  }

  download {
    "thunderbird":
      url => "http://download.mozilla.org/?product=thunderbird-2.0.0.22&os=win&lang=ca",
      creates => "Thunderbird Setup 2.0.0.22.exe";
  }

}
