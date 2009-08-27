class wpkg {

  $base = "/var/arxiver/deploy"
  $wpkg_client = "WPKG Client 1.2.1.msi"

  include wpkg::firefox
  include wpkg::thunderbird
  include wpkg::service_packs_xp
  
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
      content => template("wpkg/profiles.xml.erb");
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
  }

  exec {
    'download_wpkg_client':
      command => "wget 'http://wpkg.org/files/client/stable/$wpkg_client'",
      logoutput => false,
      cwd => "$base/software/",
      creates => "$base/software/$wpkg_client";
  }

  define download($url,$creates) {

    $download_dir = "$base/software/$name"
    
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
