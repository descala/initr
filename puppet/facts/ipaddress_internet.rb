require 'facter'
require 'open-uri'

Facter.add("ipaddress_internet") do
  setcode do
    open("http://#{Facter.value(:servername) || 'one.ingent.net'}/node/getip").read.chomp
  end
end
