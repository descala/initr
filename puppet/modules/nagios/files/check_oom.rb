#!/usr/bin/ruby
#
# check_oom.rb — plugin Nagios: detecta OOM kills del kernel al journal
#
# Cap plugin de Debian 13 ho cobreix. Lliçons: cleopatra 05/2026 (92 kills
# en bucle cada 10 min, silenci total) i t2 21/07/2026 (3 workers morts).
#
# Compta els dos tipus de kill: global ("Out of memory: Killed process") i
# de cgroup ("Memory cgroup out of memory: Killed process": un servei amb
# MemoryMax=, que és com s'han contingut els crons d'app-staging 09/2026).
# Llegeix el journal del kernel de tots els boots (no `-k`, que implica
# `-b`): un host reiniciat per sortir d'un bucle d'OOM continua avisant
# fins que la finestra expira.
#
# Sense estat: CRITICAL si hi ha kills dins la finestra crítica, WARNING
# dins la finestra ampla. Les finestres mantenen l'avís viu prou estona
# perquè es vegi encara que el check sigui passiu (NSCA).
#
# Ús: check_oom.rb [-w HORES] [-c HORES]   (defecte -w 24 -c 2)

require 'optparse'

warn_h = 24
crit_h = 2
OptionParser.new do |o|
  o.on('-w HORES', Integer) { |v| warn_h = v }
  o.on('-c HORES', Integer) { |v| crit_h = v }
end.parse!

KILL = /out of memory: Killed process/i

def kills_since(hours)
  out = `journalctl _TRANSPORT=kernel -q --no-pager -o short-iso --since "#{hours} hours ago" 2>/dev/null`
  return nil unless $?.success?
  out.lines.grep(KILL)
end

def describe(line)
  victim = line[/Killed process \d+ \([^)]*\)/] || 'unknown victim'
  scope = line.match?(/Memory cgroup/) ? 'cgroup' : 'global'
  "#{line.split(' ').first} #{victim}, #{scope}"
end

warn_kills = kills_since(warn_h)
if warn_kills.nil?
  puts 'OOM UNKNOWN - cannot read kernel journal'
  exit 3
end

if warn_kills.empty?
  puts "OOM OK - no OOM kills in last #{warn_h}h"
  exit 0
end

crit_kills = kills_since(crit_h) || []
if crit_kills.any?
  puts "OOM CRITICAL - #{crit_kills.size} OOM kill(s) in last #{crit_h}h (last: #{describe(crit_kills.last)})"
  exit 2
else
  puts "OOM WARNING - #{warn_kills.size} OOM kill(s) in last #{warn_h}h (last: #{describe(warn_kills.last)})"
  exit 1
end
