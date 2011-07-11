# Class name must match a package id in an XML in files/packages

class wpkg::googleearth {

  file {
    "$wpkg_base/software/googleearth":
      ensure => directory;
  }

  download {
    "googleearth":
      to => "googleearth",
      url => "http://dl.google.com/earth/client/GE5/release_5_2_1/GoogleEarth-Win-Bundle-5.2.1.1588.exe",
      notify => Exec['googleearth_extract'],
      creates => "GoogleEarth-Win-Bundle-5.2.1.1588.exe";
  }

  exec {
    "googleearth_extract":
      command => "/usr/bin/7za x -ov_5.2.1 GoogleEarth-Win-Bundle-5.2.1.1588.exe && chmod -R 755 v_5.2.1",
      logoutput => false,
      cwd => "$wpkg_base/software/googleearth",
      timeout => 3600,
      creates => "$wpkg_base/software/googleearth/v_5.2.1";
  }

}
