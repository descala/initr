class wpkg::sketchup8_pro inherits wpkg::sketchup8 {

  Download['sketchup8'] {
      url     => 'http://www.iscarnet.com/descargas/SketchUp+Pro+2013+Windows',
      creates => 'sketchupprowes.exe'
  }
  Exec['sketchup8_extract'] {
    command => '/usr/bin/7za x sketchupprowes.exe',
    creates => "$wpkg_base/software/sketchup/SketchUp2013.msi"
  }

}
