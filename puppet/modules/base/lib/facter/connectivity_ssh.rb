require 'facter'
require 'socket'
require 'timeout'

#TODO: make entries on /etc/hosts to do this generic
Facter.add("connectivity_ssh") do
  setcode do
    begin
      Timeout::timeout(5) {
        sock = TCPSocket.open("ssh.ingent.net", 22)
        a = sock.recvfrom(100)[0]
        sock.puts "SSH-2.0-check_ssh_test\r\n"
        sock.close
      }
      true
    rescue Exception => e
      false
    end
  end
end

