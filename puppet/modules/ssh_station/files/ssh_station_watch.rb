#!/usr/bin/env ruby

require 'socket'
require 'syslog'

begin
  sock = TCPSocket.open("localhost", 7783)
  a = sock.recvfrom(100)[0]
  sock.puts "SSH-2.0-check_ssh_test\r\n"
  sock.close
  if a =~ /SSH/
    Syslog.open("ssh_station_watch") {|log| log.debug "connection ok"}
  else
    Syslog.open("ssh_station_watch") {|log|
      log.notice "unexpected return from server: #{a}"
    }
    pid=`ps aux | grep -e '[s]sh_station\\|[s]sh -N initr' | awk '{print $2}'`
    pid.split.each do |p|
      Syslog.open("ssh_station_watch") {|log|
        log.notice "killing ssh... #{%x{kill #{p.chomp} 2>&1}}"
      }
    end
  end
rescue Exception => e
  Syslog.open("ssh_station_watch") {|log| log.notice "can't connect: #{e}"}
  pid=`ps aux | grep -e '[s]sh_station\\|[s]sh -N initr' | awk '{print $2}'`
  pid.split.each do |p|
    Syslog.open("ssh_station_watch") {|log|
      log.notice "killing ssh... #{%x{kill #{p.chomp} 2>&1}}"
    }
  end
end
