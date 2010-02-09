# From http://technet.microsoft.com/en-us/windows/bb794714.aspx

# Class name must match a package id in an XML in files/packages

class wpkg::winxp-sp3 {

  file {
    "$wpkg_base/software/service_packs_xp":
      ensure => directory;
  }

  download {
    "service_packs_xp":
      to => "service_packs_xp",
      url => "http://download.microsoft.com/download/9/4/2/942080a4-ba69-496b-a379-d3b26d37b647/WindowsXP-KB936929-SP3-x86-ESN.exe",
      creates => "WindowsXP-KB936929-SP3-x86-ESN.exe";
  }

}
