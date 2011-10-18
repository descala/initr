bind::zone { "example2.com":
  zone => "IN MX 10 smtp.example.com.\n smtp IN A 1.2.3.4",
  ttl => "300",
  serial => "2011080401",
}
