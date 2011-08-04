
Overview
========

This module manages BIND and its master DNS zones.

Variables
---------

Bind class expects 2 parameters:

* bind_masterzones: Hash with DNS zones

* nameservers: Array with ns entries for all zones

Functions
---------

Bind module defines a function to manage zones: bind::zone($zone,$ttl,$serial)

::

  bind::zone { "domain.com":
   zone   => "    IN  MX  10 smtp.ingent.net.\r\n@       IN      A       82.103.128.215\r\nwww     IN      A       82.103.128.215\r\nadmin   IN      A       82.103.128.215",
   ttl    => "300",
   serial => "2011080301",
  }


Expected external node classifier YAML
--------------------------------------

Bind is a parameterized class, when using an `external node classifier`_ classes must be a hash to pass required variables. This is an example YAML:

::
  classes:
    bind:
      bind_masterzones:
        example2.com:
          serial: "2011080401"
          ttl: "300"
          zone: "IN MX 10 smtp.example.com.\r\nsmtp IN A 1.2.3.4"
        example.com:
          serial: "2011080401"
          ttl: "300"
          zone: "@ IN A 1.2.3.4\r\nns1 IN A 1.2.3.4"
      nameservers:
        - ns1.example.com

that's:

::
  {"parameters"=>{"bind_masterzones"=>{"example2.com"=>{"serial"=>"2011080401", "ttl"=>"300", "zone"=>"IN MX 10 smtp.example.com.\r\n smtp IN A 1.2.3.4"}, "example.com"=>{"serial"=>"2011080401", "ttl"=>"300", "zone"=>"@ IN A 1.2.3.4\r\n ns1 IN A 1.2.3.4\r\n"}}, "nameservers"=>["ns1.example.com"]}}


node that apply this conf will have this 2 DNS zones:

::
  $TTL 300
  @   IN  SOA ns1.example.com.  webmaster.example.com. (
              2011080401  ; serial automatically incremented
              300         ; refresh, seconds
              7200        ; retry, seconds
              300         ; expire, seconds
              300 )       ; minimum, seconds
      IN  NS  ns1.example.com.
  @ IN A 1.2.3.4
  ns1 IN A 1.2.3.4

::
  $TTL 300
  @   IN  SOA ns1.example.com.  webmaster.example2.com. (
              2011080401  ; serial automatically incremented
              300         ; refresh, seconds
              7200        ; retry, seconds
              300         ; expire, seconds
              300 )       ; minimum, seconds
      IN  NS  ns1.example.com.
  IN MX 10 smtp.example.com.
  smtp IN A 1.2.3.4


.. _external node classifier: http://docs.puppetlabs.com/guides/external_nodes.html
