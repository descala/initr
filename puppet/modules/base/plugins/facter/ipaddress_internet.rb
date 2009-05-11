require 'facter'
require 'open-uri'

Facter.add("ipaddress_internet") do
  IPADDRESS_URL="http://#{Facter.value :servername}/node/getip"
  setcode do
    open(IPADDRESS_URL).read.chomp
  end
end