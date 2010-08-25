# From http://technet.microsoft.com/en-us/windows/bb794714.aspx

# Class name must match a package id in an XML in files/packages

class wpkg::openoffice3 {

  file {
    "$wpkg_base/software/openoffice":
      ensure => directory;
    "$wpkg_base/software/openoffice/INSTALL.txt":
      content => "Install OpenOffice.org
Manual steps required!
See http://wpkg.org/OpenOffice.org_3.x for instructions.
";
  }

  download {
    "openoffice":
      to => "openoffice",
      url => "http://ftp.udc.es/OpenOffice/localized/ca/3.2.1/OOo_3.2.1_Win_x86_install-wJRE_ca.exe",
      creates => "OOo_3.2.1_Win_x86_install-wJRE_ca.exe";
  }

}
