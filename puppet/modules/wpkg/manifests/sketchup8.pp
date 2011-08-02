# Class name must match a package id in an XML in files/packages

# http://sketchup.google.com/gsu8/download.html
# Free         = http://dl.google.com/sketchup/GoogleSketchUpWES.exe
# Professional = http://dl.google.com/sketchup/GoogleSketchUpProWES.exe

class wpkg::sketchup8 {

  file {
    "$wpkg_base/software/sketchup":
      ensure => directory;
  }

  wpkg::download {
    "sketchup8":
      to => "sketchup",
      url => "http://dl.google.com/sketchup/GoogleSketchUpWES.exe",
      creates => "GoogleSketchUp8WES.exe";
  }

  exec {
    "sketchup8_extract":
      command => "/usr/bin/7za x GoogleSketchUp8WES.exe",
      logoutput => false,
      cwd => "$wpkg_base/software/sketchup",
      timeout => 3600,
      creates => "$wpkg_base/software/sketchup/GoogleSketchUp8.msi";
  }

}

