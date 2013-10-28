require 'facter'
require 'open-uri'

Facter.add("ipaddress_internet") do
  setcode do
    i=0
    ip=''
    re=/([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
    while i<5 and ip.empty?
      begin
        ip=open("http://curlmyip.com/").read.match(re).captures.first
      rescue Exception => e
        Facter.warnonce "Failed to get ip from curlmyip.com: #{e.message}"
      ensure
        i += 1
      end
    end
    ip
  end
end
