#!/usr/bin/ruby
#
# check_nfs_write_canary.rb — plugin Nagios: latència d'escriptura al muntatge NFS
#
# t1 04/2026: export amb sync + mount sense async = ~60ms per close() i un
# batch SII de 20+ hores. check_nfsmounts (contrib) detecta muntatges morts;
# aquest mesura la DEGRADACIÓ: escriu N fitxers petits amb fsync i n'informa
# la mediana en ms. El treball es fa en un fork amb timeout perquè un NFS
# penjat (D-state) no deixi el check penjat per sempre.
#
# Ús: check_nfs_write_canary.rb -d DIR [-w MS] [-c MS] [-t SEGONS] [-n N]
#   (defectes: -w 25 -c 100 -t 30 -n 5; DIR ha de ser escrivible pel client
#    — compte amb el root_squash: trieu un directori del propietari app)
#
# Si el muntatge està penjat de debò, el fill queda en estat D i el KILL no
# el mata: cada passada en deixa un d'orfe fins que el muntatge torna. És
# esperat; el problema és el muntatge, no el check.

require 'optparse'
require 'socket'

dir = nil
warn_ms = 25.0
crit_ms = 100.0
timeout = 30
iters = 5
OptionParser.new do |o|
  o.on('-d DIR') { |v| dir = v }
  o.on('-w MS', Float) { |v| warn_ms = v }
  o.on('-c MS', Float) { |v| crit_ms = v }
  o.on('-t SEGONS', Integer) { |v| timeout = v }
  o.on('-n N', Integer) { |v| iters = v }
end.parse!
abort 'usage: check_nfs_write_canary.rb -d DIR [-w ms] [-c ms]' unless dir

r, w = IO.pipe
pid = fork do
  r.close
  data = 'x' * 4096
  times = iters.times.map do |i|
    f = File.join(dir, ".nfs-canary-#{Socket.gethostname.split('.').first}-#{Process.pid}-#{i}")
    t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    File.open(f, 'w') { |io| io.write(data); io.fsync }
    File.unlink(f)
    (Process.clock_gettime(Process::CLOCK_MONOTONIC) - t0) * 1000
  end
  w.puts times.join(',')
  exit! 0
rescue StandardError => e
  w.puts "ERR #{e.class}: #{e.message}"
  exit! 1
end
w.close

unless IO.select([r], nil, nil, timeout)
  Process.kill('KILL', pid) rescue nil
  Process.detach(pid)
  puts "NFS WRITE CRITICAL - no response from #{dir} after #{timeout}s (mount hung?)"
  exit 2
end
line = r.gets.to_s.strip
Process.wait(pid)

if line.empty? || line.start_with?('ERR')
  puts "NFS WRITE UNKNOWN - #{line.empty? ? 'no data from worker' : line} (#{dir})"
  exit 3
end

times = line.split(',').map(&:to_f)
med = times.sort[times.size / 2]
max = times.max
perf = "|median=#{med.round(2)}ms;#{warn_ms};#{crit_ms} max=#{max.round(2)}ms"
if med >= crit_ms
  puts "NFS WRITE CRITICAL - median #{med.round(1)}ms over #{iters} ops on #{dir} #{perf}"
  exit 2
elsif med >= warn_ms
  puts "NFS WRITE WARNING - median #{med.round(1)}ms over #{iters} ops on #{dir} #{perf}"
  exit 1
else
  puts "NFS WRITE OK - median #{med.round(1)}ms max #{max.round(1)}ms on #{dir} #{perf}"
  exit 0
end
