class wpkg::libreoffice {

  file {
    "$wpkg_base/software/libreoffice":
      ensure => directory;
  }

  wpkg::download {
    'libreoffice':
      to      => 'libreoffice',
      url     => 'http://ftp.rediris.es/mirror/TDF/libreoffice/stable/4.2.4/win/x86/LibreOffice_4.2.4_Win_x86.msi',
      creates => 'LibreOffice_4.2.4_Win_x86.msi';
  }
}
