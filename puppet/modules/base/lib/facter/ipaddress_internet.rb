require 'facter'
require 'open-uri'

Facter.add(:ipaddress_internet) do
  setcode do
    ip=''
    re=/([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
    %w(http://checkip.amazonaws.com/ http://wtfismyip.com/text http://icanhazip.com).each do |url|
      begin
        ip=open(url).read.match(re).captures.first
        break if ip
      rescue Exception => e
        Facter.warnonce "Failed to get ip from #{url}: #{e.message}"
      end
    end
    ip
  end
end
