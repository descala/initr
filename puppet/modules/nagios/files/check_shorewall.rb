#!/usr/bin/ruby
#
# check_shorewall.rb — plugin Nagios: tallafocs actiu amb política INPUT DROP
#
# Lliçó del 29/07/2026 a drp-fs: shorewall instal·lat però no habilitat =
# rpcbind (:111) obert a internet durant mesos amb connexions ESTAB d'IPs
# aleatòries, sense que ho veiés ningú.
#
# No instal·lat també és CRITICAL: als hosts de la farm l'estat desitjat és
# tallafocs actiu, i un UNKNOWN sovint no arriba a avisar ningú.

status = `shorewall status 2>&1`
if $?.exitstatus == 127
  puts 'SHOREWALL CRITICAL - shorewall not installed'
  exit 2
end

running = status.match?(/Shorewall is running/)
policy = `iptables -S INPUT 2>/dev/null`.lines.first.to_s.strip

problems = []
problems << 'shorewall not running' unless running
problems << "INPUT policy is #{policy.split.last || 'unknown'}" unless policy == '-P INPUT DROP'

if problems.any?
  puts "SHOREWALL CRITICAL - #{problems.join('; ')}"
  exit 2
end
puts 'SHOREWALL OK - running, INPUT policy DROP'
exit 0
