class wpkg::libreoffice {

  file {
    "$wpkg_base/software/libreoffice":
      ensure => directory;
  }

  wpkg::download {
    'libreoffice':
      to      => 'libreoffice',
      url     => 'http://donate.libreoffice.org/home/dl/win-x86/4.2.4/ca/LibreOffice_4.2.4_Win_x86.msi',
      creates => 'LibreOffice_4.2.4_Win_x86.msi';
  }
}
