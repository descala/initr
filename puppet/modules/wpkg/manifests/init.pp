# Import required for external nodes to find wpkg::package classes
import "*.pp"

class wpkg {

  $client = "WPKG Client 1.2.1.msi"

  file {
    [$wpkg_base,"$wpkg_base/wpkg","$wpkg_base/software","$wpkg_base/settings","$wpkg_base/scripts","$wpkg_base/wpkg/hosts","$wpkg_base/wpkg/profiles"]:
      ensure => directory;
    "$wpkg_base/settings/client-settings.xml":
      content => template("wpkg/client-settings.xml.erb");
    "$wpkg_base/install.bat":
      content => template("wpkg/install.bat.erb");
    "/etc/samba/wpkg_smb.conf":
      source => "puppet:///wpkg/wpkg_smb.conf",
      mode => 664;
    "$wpkg_base/wpkg/wpkg.js":
      source => "puppet:///wpkg/wpkg.js";
    "$wpkg_base/wpkg/hosts/default.xml":
      source => "puppet:///wpkg/hosts-default.xml";
    "$wpkg_base/wpkg/profiles/default.xml":
      content => template("wpkg/profiles.xml.erb");
    "$wpkg_base/wpkg/hosts.xml":
      ensure => "hosts/default.xml";    
    "$wpkg_base/wpkg/profiles.xml":
      ensure => "profiles/default.xml";    
    "$wpkg_base/wpkg/packages.xml":
      ensure => "packages/default.xml";    
    "$wpkg_base/wpkg/packages/":
      source => "puppet:///wpkg/packages",
      recurse => true,
      ignore => ".svn";
    "$wpkg_base/scripts/wpkg_before.bat":
      source => "puppet:///wpkg/wpkg_before.bat";
    "$wpkg_base/scripts/wpkg_after.bat":
      source => "puppet:///wpkg/wpkg_after.bat";
  }

  exec {
    'download_wpkg_client':
      command => "wget 'http://wpkg.org/files/client/stable/$client'",
      logoutput => false,
      cwd => "$wpkg_base/software/",
      creates => "$wpkg_base/software/$client";
  }

  define download($url,$creates) {

    $download_dir = "$wpkg_base/software/$name"
    
    exec {
      "wpkg_$name":
        command => "wget -O '$creates' '$url'",
        logoutput => false,
        cwd => $download_dir,
        require => File[$download_dir],
        timeout => 3600,
        creates => "$download_dir/$creates";
    }

  }
  
}
