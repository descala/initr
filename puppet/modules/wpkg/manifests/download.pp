define wpkg::download($to,$url,$creates) {

  $download_dir = "$wpkg_base/software/$to"

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

