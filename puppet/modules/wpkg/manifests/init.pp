class wpkg {

  $base = "/var/arxiver/deploy"
  $wpkg_client = "WPKG Client 1.2.1.msi"
  
  file {
    [$base,"$base/wpkg","$base/software","$base/settings","$base/scripts","$base/wpkg/hosts","$base/wpkg/profiles"]:
      ensure => directory;
    "$base/settings/client-settings.xml":
      content => template("wpkg/client-settings.xml.erb");
    "$base/install.bat":
      content => template("wpkg/install.bat.erb");
    "/etc/samba/wpkg_smb.conf":
      source => "puppet:///wpkg/wpkg_smb.conf",
      mode => 664;
    "$base/wpkg/wpkg.js":
      source => "puppet:///wpkg/wpkg.js";
    "$base/wpkg/hosts/default.xml":
      source => "puppet:///wpkg/hosts-default.xml";
    "$base/wpkg/profiles/default.xml":
      source => "puppet:///wpkg/profiles-default.xml";
    "$base/wpkg/hosts.xml":
      ensure => "hosts/default.xml";    
    "$base/wpkg/profiles.xml":
      ensure => "profiles/default.xml";    
    "$base/wpkg/packages.xml":
      ensure => "packages/default.xml";    
    "$base/wpkg/packages/":
      source => "puppet:///wpkg/packages",
      recurse => true,
      ignore => ".svn";
    "$base/scripts/wpkg_before.bat":
      source => "puppet:///wpkg/wpkg_before.bat";
    "$base/scripts/wpkg_after.bat":
      source => "puppet:///wpkg/wpkg_after.bat";
    "$base/software/get_software.sh":
      source => "puppet:///wpkg/get_software.sh",
      mode => 755;
  }

  exec {
    'download_wpkg_client':
      command => "wget 'http://wpkg.org/files/client/stable/$wpkg_client'",
      logoutput => false,
      cwd => "$base/software/",
      creates => "$base/software/$wpkg_client";
  }

}
