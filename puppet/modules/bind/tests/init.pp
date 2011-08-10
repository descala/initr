class { "bind":
  nameservers => [ "ns1.example.com", "ns2.example.com" ],
  bind_masterzones => {
    "example2.com" => {
      "serial" => "2011080401",
      "ttl" => "300",
      "zone" => "IN MX 10 smtp.example.com.\n smtp IN A 1.2.3.4" },
    "example.com" => {
      "serial" => "2011080401",
      "ttl" => "300",
      "zone" => "@ IN A 1.2.3.4\n ns1 IN A 1.2.3.4" }
  },
}
