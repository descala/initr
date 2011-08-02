# From http://www.mozilla.com/en-US/firefox/all.html

# Class name must match a package id in an XML in files/packages

class wpkg::firefox {

  file {
    "$wpkg_base/software/firefox":
      ensure => directory;
  }

}

