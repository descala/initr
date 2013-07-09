class common::decompressors {

  case $operatingsystem {
    "Debian": {
      package {
        ["arj","bzip2","cabextract","cpio","file","gzip",$lha,
        "nomarch","pax","rar","unrar","unzip","zip","zoo"]:
          ensure => installed;
      }
    }
    default: {
      #todo
    }
  }

}
