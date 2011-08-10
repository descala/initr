class wpkg($wpkg_base,$wpkg_profiles) {

  $client = "WPKG Client 1.2.1.msi"

  file {
    [$wpkg_base,"$wpkg_base/wpkg","$wpkg_base/software","$wpkg_base/settings","$wpkg_base/scripts","$wpkg_base/wpkg/hosts","$wpkg_base/wpkg/profiles"]:
      ensure => directory;
    "$wpkg_base/settings/client-settings.xml":
      content => template("wpkg/client-settings.xml.erb");
    "$wpkg_base/install.bat":
      content => template("wpkg/install.bat.erb");
    "/etc/samba/wpkg_smb.conf":
      source => "puppet:///modules/wpkg/wpkg_smb.conf",
      mode => 664;
    "$wpkg_base/wpkg/wpkg.js":
      source => "puppet:///modules/wpkg/wpkg.js";
    "$wpkg_base/wpkg/hosts/default.xml":
      source => "puppet:///modules/wpkg/hosts-default.xml";
    "$wpkg_base/wpkg/profiles/default.xml":
      content => template("wpkg/profiles.xml.erb");
    "$wpkg_base/wpkg/hosts.xml":
      ensure => "hosts/default.xml";
    "$wpkg_base/wpkg/profiles.xml":
      ensure => "profiles/default.xml";
    "$wpkg_base/wpkg/packages.xml":
      ensure => "packages/default.xml";
    "$wpkg_base/wpkg/packages/":
      source => "puppet:///modules/wpkg/packages",
      recurse => true,
      ignore => ".svn";
    "$wpkg_base/scripts/wpkg_before.bat":
      source => "puppet:///modules/wpkg/wpkg_before.bat";
    "$wpkg_base/scripts/wpkg_after.bat":
      source => "puppet:///modules/wpkg/wpkg_after.bat";
  }

  exec {
    'download_wpkg_client':
      command => "wget 'http://wpkg.org/files/client/stable/$client'",
      logoutput => false,
      cwd => "$wpkg_base/software/",
      creates => "$wpkg_base/software/$client",
      require => File["$wpkg_base/software"];
  }

  package { $p7zip_package:
    ensure => installed;
  }

}
