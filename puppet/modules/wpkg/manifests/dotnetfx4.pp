# Class name must match a package id in an XML in files/packages

class wpkg::dotnetfx4 {

  file {
    "$wpkg_base/software/dotnetfx4":
      ensure => directory;
  }

  wpkg::download {
    'dotnetfx4':
      to      => 'dotnetfx4',
      url     => 'http://download.microsoft.com/download/9/5/A/95A9616B-7A37-4AF6-BC36-D6EA96C8DAAE/dotNetFx40_Full_x86_x64.exe',
      creates => 'dotNetFx40_Full_x86_x64.exe';
  }

}

