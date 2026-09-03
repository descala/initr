#!/usr/bin/ruby
#
# check_disk_forecast.rb — plugin Nagios: previsió de dies fins a disc ple
#
# El check_disk clàssic avisa quan ja és tard: bk2 07/2026 (una setmana
# omplint-se fins a matar la rèplica), app-staging 07/2026 (56 GB en 3
# setmanes fins al 100%). Aquest guarda mostres d'ús a /var/tmp i estima,
# per regressió lineal sobre la finestra, quants dies falten perquè el
# filesystem s'ompli al ritme actual.
#
# Ús: check_disk_forecast.rb -p PATH [-w DIES] [-c DIES] [--window DIES]
#   (defectes: -w 7 -c 3 --window 7; cal >=24h de mostres per pronosticar)
#
# Soroll esperat: la regressió és lineal sobre la finestra, així que un salt
# puntual (una importació massiva, un dump deixat a /srv) es projecta com a
# creixement durant dies. --window més curt reacciona abans i oblida abans.

require 'optparse'
require 'json'
require 'shellwords'

path = nil
warn_d = 7.0
crit_d = 3.0
window_d = 7.0
OptionParser.new do |o|
  o.on('-p PATH') { |v| path = v }
  o.on('-w DIES', Float) { |v| warn_d = v }
  o.on('-c DIES', Float) { |v| crit_d = v }
  o.on('--window DIES', Float) { |v| window_d = v }
end.parse!
abort 'usage: check_disk_forecast.rb -p PATH [-w days] [-c days]' unless path

def human(bytes)
  return format('%.1fG', bytes / 1024.0**3) if bytes.abs >= 1024**3
  format('%.0fM', bytes / 1024.0**2)
end

df = `df -kP #{Shellwords.escape(path)} 2>/dev/null`.lines[1]
if df.nil?
  puts "DISK FORECAST UNKNOWN - df failed for #{path}"
  exit 3
end
used = df.split[2].to_i * 1024
avail = df.split[3].to_i * 1024

state_file = "/var/tmp/check_disk_forecast#{path.tr('/', '_')}.json"
samples = JSON.parse(File.read(state_file)) rescue []
samples = [] unless samples.is_a?(Array)
now = Time.now.to_i
samples << [now, used]
samples.select! { |t, _| t.is_a?(Integer) && t > now - (window_d * 86_400).to_i }
File.write(state_file, JSON.generate(samples))

span_h = (samples.last[0] - samples.first[0]) / 3600.0
if span_h < 24
  puts "DISK FORECAST OK - #{path}: collecting baseline (#{span_h.round(1)}h of 24h)"
  exit 0
end

# regressió lineal used = a + b*t (t relatiu a la primera mostra)
t0 = samples.first[0]
n = samples.size.to_f
sum_t = samples.sum { |t, _| t - t0 }
sum_u = samples.sum { |_, u| u }
sum_tt = samples.sum { |t, _| (t - t0)**2 }
sum_tu = samples.sum { |t, u| (t - t0) * u }
denom = n * sum_tt - sum_t**2
slope = denom.zero? ? 0.0 : (n * sum_tu - sum_t * sum_u) / denom # bytes/segon
per_day = slope * 86_400

if per_day <= 0
  puts "DISK FORECAST OK - #{path}: not growing over last #{span_h.round}h (#{human(avail)} free)"
  exit 0
end

days_left = avail / per_day
msg = "#{path}: full in ~#{days_left.round(1)} days at +#{human(per_day)}/day (#{human(avail)} free)"
if days_left <= crit_d
  puts "DISK FORECAST CRITICAL - #{msg}"
  exit 2
elsif days_left <= warn_d
  puts "DISK FORECAST WARNING - #{msg}"
  exit 1
else
  puts "DISK FORECAST OK - #{msg}"
  exit 0
end
