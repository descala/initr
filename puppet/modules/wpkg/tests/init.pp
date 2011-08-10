class { "wpkg":
    wpkg_base => "/srv/samba/deploy",
    wpkg_profiles => {
      "default" => [ "winxp_sp3", "firefox5" ]
    },
}
