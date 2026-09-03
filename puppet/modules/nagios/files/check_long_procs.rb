#!/usr/bin/ruby
#
# check_long_procs.rb — plugin Nagios: processos que porten massa temps corrent
#
# Detecta jobs penjats que aguanten un flock o un lock de borg durant dies
# en silenci: rsync de rèplica penjat 30 dies (drp-fs 06/2026) i 9 dies
# (07/2026), borg create solapant-se >24h (bk 08/2026).
#
# Ús: check_long_procs.rb -C REGEX [-w HORES] [-c HORES]
#   -C  regex sobre la línia de comanda completa (ps args)
#   -w  llindar WARNING en hores (defecte 24)
#   -c  llindar CRITICAL en hores (defecte 48)
#
# Compte amb els scripts interpretats: `ps` mostra l'intèrpret al davant
# (borg a Debian és `/usr/bin/python3 /usr/bin/borg create ...`), així que
# no ancoreu el regex amb ^. I un patró d'rsync casa amb les dues bandes
# (el `rsync --server` receptor també), que és el que volem: un receptor
# penjat és tan greu com un emissor penjat.

require 'optparse'

pattern = nil
warn_h = 24
crit_h = 48
OptionParser.new do |o|
  o.on('-C REGEX') { |v| pattern = Regexp.new(v) }
  o.on('-w HORES', Integer) { |v| warn_h = v }
  o.on('-c HORES', Integer) { |v| crit_h = v }
end.parse!
abort 'usage: check_long_procs.rb -C REGEX [-w hours] [-c hours]' unless pattern

def fmt(seconds)
  d, rest = seconds.divmod(86_400)
  h, rest = rest.divmod(3600)
  d.positive? ? "#{d}d#{h}h" : "#{h}h#{rest / 60}m"
end

me = Process.pid
# s'exclou a si mateix i el wrapper/shell que porta el regex a la seva cmdline
procs = `ps -eo pid=,etimes=,args=`.lines.filter_map do |line|
  pid, etimes, args = line.strip.split(' ', 3)
  next if args.nil? || pid.to_i == me || args.include?(File.basename(__FILE__))
  [pid.to_i, etimes.to_i, args] if args =~ pattern
end

if procs.empty?
  puts "PROCS OK - no processes matching #{pattern.source}"
  exit 0
end

pid, etimes, args = procs.max_by { |_, e, _| e }
msg = "pid #{pid} running #{fmt(etimes)}: #{args[0, 80]}"
if etimes >= crit_h * 3600
  puts "PROCS CRITICAL - #{msg} (limit #{crit_h}h)"
  exit 2
elsif etimes >= warn_h * 3600
  puts "PROCS WARNING - #{msg} (limit #{warn_h}h)"
  exit 1
else
  puts "PROCS OK - #{procs.size} matching, oldest #{fmt(etimes)} (pid #{pid})"
  exit 0
end
