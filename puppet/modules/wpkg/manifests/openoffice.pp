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
      url => "http://www.softcatala.org/pub/softcatala/openoffice/3.1/windows/OOo_3.1.0_Win32Intel_install_ca.exe",
      creates => "OOo_3.1.0_Win32Intel_install_ca.exe";
  }

}
