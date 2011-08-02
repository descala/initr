class common::perl {
  package {
    [$perl_net_dns, $perl_net_ip, $perl_geo_ipfree, $perl_net_xwhois]:
      ensure => installed;
  }
}

