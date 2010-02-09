# Class name must match a package id in an XML in files/packages

# Free         = http://dl.google.com/sketchup/GoogleSketchUpWES.exe
# Professional = http://dl.google.com/sketchup/GoogleSketchUpProWES.exe

class wpkg::sketchup7 {

  file {
    "$wpkg_base/software/sketchup":
      ensure => directory;
    "$wpkg_base/software/sketchup/readme.txt":
      content => "http://wpkg.org/Sketchup

The download file is an .exe that does not accept the default silent switches. Run a manual install using the .exe on a test PC. It extracts the .msi to a temp file (see http://www.appdeploy.com/messageboards/tm.asp?m=42458) which can be used successfully as your instalaltion msi.

WPKG will look for GoogleSketchUp7.msi in this folder.
";
  }

  download {
    "sketchup7":
      to => "sketchup",
      url => "http://dl.google.com/sketchup/GoogleSketchUpWES.exe",
      creates => "GoogleSketchUpWES.exe";
  }

}

class wpkg::sketchup7-pro inherits wpkg::sketchup7{

  download {
    "sketchup7-pro":
      to => "sketchup",
      url => "http://dl.google.com/sketchup/GoogleSketchUpProWES.exe",
      creates => "GoogleSketchUpProWES.exe";
  }

}
