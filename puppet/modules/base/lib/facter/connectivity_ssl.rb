require 'facter'
require 'socket'
require 'timeout'

#TODO: make entries on /etc/hosts to do this generic
Facter.add("connectivity_ssl") do
  setcode do
    begin
      Timeout::timeout(5) {
        sock = TCPSocket.open("one.ingent.net", 443)
        sock.close
      }
      true
    rescue Exception => e
      false
    end
  end
end

