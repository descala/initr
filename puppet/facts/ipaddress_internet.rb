require 'facter'
require 'open-uri'

Facter.add("ipaddress_internet") do
  setcode do
    open("http://checkip.dyndns.org/").read.match(/Current IP Address: ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/).captures.first rescue nil
  end
end
