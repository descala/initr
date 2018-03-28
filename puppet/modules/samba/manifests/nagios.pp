class samba::nagios {
  file {
    "$nagios_plugins_dir/check_smb":
      source => "puppet:///modules/samba/check_smb.sh",
      mode => 0755;
    "$nagios_plugins_dir/check_winbind":
      source => "puppet:///modules/samba/check_winbind.sh",
      mode => 0755;
  }
  nagios::check { "smb":
    command => "check_smb localhost $nagios_smbuser $nagios_smbpass",
  }
}

