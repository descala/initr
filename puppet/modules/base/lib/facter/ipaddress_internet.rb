require 'facter'
require 'open-uri'

Facter.add("ipaddress_internet") do
  setcode do
    begin
      open("http://checkip.dyndns.org/").read.match(/Current IP Address: ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/).captures.first
    rescue Exception => e
      e.message
    end
  end
end
