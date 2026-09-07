#!/usr/bin/ruby
#
# check_smart.rb — plugin Nagios: salut SMART de tots els discos del host
#
# El servei `smartd` de la flota és passiu i sense frescor (check_freshness 0):
# només parla quan smartd envia un correu i es queda clavat a l'últim estat
# per sempre — ha2 va portar 97 dies un "Critical Warning" d'un disc ja
# substituït, i `ha` fa 5 anys que diu OK. I `smartctl -H` sol no serveix: el
# sdb de drp-fs (09/2026) deia PASSED amb 48 sectors pendents, 30 incorregibles
# i el self-test fallant, perquè aquests atributs tenen llindar 000. Aquest
# check pregunta cada hora amb `smartctl -j` a tots els discos que
# `smartctl --scan-open` troba (SATA, NVMe, i els físics darrere d'un megaraid).
#
# CRITICAL: salut != PASSED; atribut ATA marcat FAILING_NOW; sectors pendents
#   (197) o incorregibles offline (198) > 0; últim self-test fallat; NVMe amb
#   critical_warning != 0 o available_spare per sota del seu llindar.
# WARNING: comptadors de vida que han CRESCUT dins la finestra (defecte 24h):
#   Reallocated_Sector_Ct (5), Reported_Uncorrect (187), Reallocated_Event_Count
#   (196), UDMA_CRC_Error_Count (199), media_errors (NVMe); i NVMe amb
#   percentage_used >= -w (defecte 90). Un comptador alt però estable només
#   s'informa entre claudàtors: el sdb de fs1 porta anys amb Reported_Uncorrect=12
#   i no ha de ser un ack etern.
#
# Ús: check_smart.rb [-w PCT] [-x DEV[,DEV]] [--window HORES] [-s FITXER]
#   -x  discos a ignorar pel nom curt (sda) o pel tipus (sat+megaraid,4)
#   -s  fitxer d'estat pels comptadors (defecte /var/tmp/check_smart.json)
#
# Necessita smartmontools (smartctl >= 7.0 per -j; la flota té 7.2–7.4).

require 'optparse'
require 'json'
require 'shellwords'

# El cron de root corre amb PATH=/usr/bin:/bin i smartctl és a /usr/sbin.
ENV['PATH'] = "/usr/sbin:/sbin:#{ENV['PATH']}"

warn_used = 90
exclude = []
window_h = 24.0
state_file = '/var/tmp/check_smart.json'
OptionParser.new do |o|
  o.on('-w PCT', Integer) { |v| warn_used = v }
  o.on('-x DEVS') { |v| exclude.concat(v.split(',')) }
  o.on('--window HORES', Float) { |v| window_h = v }
  o.on('-s FITXER') { |v| state_file = v }
end.parse!

unless ENV['PATH'].split(':').any? { |d| File.executable?(File.join(d, 'smartctl')) }
  puts 'SMART UNKNOWN - smartctl not found (install smartmontools)'
  exit 3
end

# smartctl -j retorna JSON també quan falla (l'error va a smartctl.messages).
# timeout: un disc SATA penjat pot bloquejar smartctl indefinidament.
def smartctl(*args)
  out = `timeout 60 smartctl -j #{args.shelljoin} 2>/dev/null`
  JSON.parse(out)
rescue JSON::ParserError
  nil
end

# Comptadors de vida: creixen i no tornen enrere; només avisa el creixement.
ATA_COUNTERS = { 5 => 'Reallocated_Sector_Ct', 187 => 'Reported_Uncorrect',
                 196 => 'Reallocated_Event_Count', 199 => 'UDMA_CRC_Error_Count' }.freeze
# Sectors que ARA no es poden llegir: crític encara que la salut digui PASSED.
ATA_CRITICAL = { 197 => 'Current_Pending_Sector', 198 => 'Offline_Uncorrectable' }.freeze

scan = smartctl('--scan-open')
devices = (scan && scan['devices']) || []
devices.reject! { |d| exclude.include?(File.basename(d['name'].to_s)) || exclude.include?(d['type']) }
if devices.empty?
  puts 'SMART UNKNOWN - smartctl --scan-open found no devices'
  exit 3
end

state = JSON.parse(File.read(state_file)) rescue {}
state = {} unless state.is_a?(Hash)
now = Time.now.to_i
cutoff = now - (window_h * 3600).to_i

crit = []
warn = []
notes = []
ok_names = []
skipped = []

devices.each do |dev|
  # /dev/bus/0 amb -d sat+megaraid,4 → "megaraid,4"; la resta pel nom curt
  label = dev['type'].to_s.include?('megaraid') ? dev['type'].sub('sat+', '') : File.basename(dev['name'].to_s)
  d = smartctl('-H', '-A', '-l', 'selftest', '-d', dev['type'], dev['name'])
  if d.nil?
    crit << "#{label}: smartctl returned no JSON (hung?)"
    next
  end
  status = d.fetch('smartctl', {})
  if (status['exit_status'].to_i & 2) != 0 # bit 1: no s'ha pogut obrir el dispositiu
    if dev['protocol'] == 'SCSI'
      # discos virtuals d'un controlador RAID: no tenen SMART; els físics ja surten com megaraid,N
      skipped << label
    else
      crit << "#{label}: #{(status['messages'] || []).map { |m| m['string'] }.join('; ')}"
    end
    next
  end

  problems = []
  counters = {}
  problems << 'health FAILED' if d.dig('smart_status', 'passed') == false

  if (h = d['nvme_smart_health_information_log'])
    cw = h['critical_warning'].to_i
    problems << format('critical_warning=0x%02x', cw) if cw != 0
    spare, spare_th = h['available_spare'], h['available_spare_threshold']
    problems << "available_spare #{spare}% < #{spare_th}%" if spare && spare_th && spare < spare_th
    used = h['percentage_used'].to_i
    warn << "#{label}: #{used}% used" if used >= warn_used
    counters['media_errors'] = h['media_errors'].to_i
  end

  (d.dig('ata_smart_attributes', 'table') || []).each do |a|
    id = a['id'].to_i
    raw = a.dig('raw', 'value').to_i
    problems << "#{a['name']} FAILING_NOW" if a['when_failed'].to_s == 'now'
    problems << "#{ATA_CRITICAL[id]}=#{raw}" if ATA_CRITICAL[id] && raw > 0
    counters[ATA_COUNTERS[id]] = raw if ATA_COUNTERS[id]
  end

  # l'entrada 0 del log és la més recent. Un test avortat (reinici del controlador,
  # apagada, ordre de l'host) no és un test fallat: drp-ha en tenia als dos NVMe.
  last = (d.dig('ata_smart_self_test_log', 'standard', 'table') || []).first
  if last && last.dig('status', 'passed') == false && last.dig('status', 'string').to_s !~ /aborted|interrupted|in progress/i
    problems << "self-test #{last.dig('status', 'string')}"
  end
  nlast = (d.dig('nvme_self_test_log', 'table') || []).first
  # NVMe: 0 = sense error; 1-4, 8, 9 = avortat per diverses causes; 5-7 = fallada real
  if nlast && [5, 6, 7].include?(nlast.dig('self_test_result', 'value').to_i)
    problems << "self-test #{nlast.dig('self_test_result', 'string')}"
  end

  # creixement dels comptadors dins la finestra (la primera mostra és la base)
  key = d['serial_number'] || "#{dev['name']} #{dev['type']}"
  samples = (state[key] || []).select { |t, _| t.is_a?(Integer) && t >= cutoff }
  samples << [now, counters]
  state[key] = samples
  base = samples.first[1] || {}
  counters.each do |name, val|
    grew = val - base[name].to_i
    if grew > 0 && base.key?(name)
      warn << "#{label}: #{name} +#{grew} in #{window_h.round}h (now #{val})"
    elsif val > 0
      notes << "#{label} #{name}=#{val}"
    end
  end

  if problems.any?
    crit << "#{label}: #{problems.join(', ')}"
  else
    ok_names << label
  end
end

File.write(state_file, JSON.generate(state)) rescue nil

# (def clàssic: db1, ha i cleopatra encara corren ruby 2.7)
def plural(n, word)
  "#{n} #{word}#{'s' unless n == 1}"
end

summary = []
summary << "#{plural(ok_names.size, 'other disk')} OK" if ok_names.any? && (crit.any? || warn.any?)
summary << "#{skipped.size} without SMART (#{skipped.join(' ')})" if skipped.any?
summary << "notes: #{notes.join(', ')}" if notes.any?
tail = summary.empty? ? '' : " [#{summary.join('; ')}]"

# nsca_wrapper només envia la primera línia: tot en una.
if crit.any?
  puts "SMART CRITICAL - #{crit.join(' | ')}#{tail}"
  exit 2
elsif warn.any?
  puts "SMART WARNING - #{warn.join(' | ')}#{tail}"
  exit 1
else
  puts "SMART OK - #{plural(ok_names.size, 'disk')} healthy (#{ok_names.join(' ')})#{tail}"
  exit 0
end
