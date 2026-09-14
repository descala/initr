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
# Excepció (vegeu `nvme_wear_only?`): un NVMe que ha passat la seva vida
# nominal i no té cap altra evidència de dany és WARNING, no CRITICAL.
#
# Ús: check_smart.rb [-w PCT] [-x DEV[,DEV]] [--window HORES] [-s FITXER]
#   -x  discos a ignorar pel nom curt (sda) o pel tipus (sat+megaraid,4)
#   -s  fitxer d'estat pels comptadors (defecte /var/tmp/check_smart.json)
#
# Necessita smartmontools (smartctl >= 7.0 per -j; la flota té 7.2–7.4).
#
# ⚠ Debian bullseye porta Ruby 2.7 i trixie 3.3: res d'endless methods
# (`def f(x) = ...`), que a 2.7 són syntax error, ni de `File.exists?`, que ja
# no hi és a 3.3. `test_check_smart.rb` d'aquest directori corre a totes dues.

require 'optparse'
require 'json'
require 'shellwords'

# Comptadors de vida: creixen i no tornen enrere; només avisa el creixement.
ATA_COUNTERS = { 5 => 'Reallocated_Sector_Ct', 187 => 'Reported_Uncorrect',
                 196 => 'Reallocated_Event_Count', 199 => 'UDMA_CRC_Error_Count' }.freeze
# Sectors que ARA no es poden llegir: crític encara que la salut digui PASSED.
ATA_CRITICAL = { 197 => 'Current_Pending_Sector', 198 => 'Offline_Uncorrectable' }.freeze

# Bit 2 de `critical_warning`: "NVM subsystem reliability has been degraded".
NVME_CW_RELIABILITY = 0x04

# smartctl -j retorna JSON també quan falla (l'error va a smartctl.messages).
# timeout: un disc SATA penjat pot bloquejar smartctl indefinidament.
def smartctl(*args)
  out = `timeout 60 smartctl -j #{args.shelljoin} 2>/dev/null`
  JSON.parse(out)
rescue JSON::ParserError
  nil
end

# Cert quan l'únic motiu de l'avís d'un NVMe és el desgast: només el bit de
# fiabilitat, cap error de mitjà, spare intacte i vida nominal ja superada.
#
# El bit 2 diu "fiabilitat degradada", però hi ha firmware (Samsung PM981,
# entre d'altres) que l'aixeca quan `percentage_used` passa del 100 %, o sigui
# quan s'acaba la garantia i no quan hi ha cap error: el disc segueix amb
# media_errors=0, l'spare al 100 %, cap error de kernel i el checkarray net.
# Altres fabricants (Toshiba KXG60) no l'aixequen mai, ni al 145 % de vida.
# És comportament de firmware, no diagnòstic, i el proveïdor no el pot
# desactivar: recomana filtrar-lo a la monitorització.
#
# Sense filtre, dos discos en el mateix estat real es reporten CRITICAL o
# WARNING segons qui els ha fabricat: això és avisar del firmware i no del
# risc. El que sí que és real —els dos costats d'un mirall que es gasten
# alhora, perquè reben les mateixes escriptures— no es cura amb una
# notificació nocturna, es planifica.
#
# El llindar del 100 % és el que manté el filtre honest: el mateix bit a un
# disc amb vida de sobres no és desgast sinó una fallada interna del
# controlador, i continua sent CRITICAL. Per això tampoc no val amb `spare`
# nul: sense poder comprovar que l'spare està sencer, no es rebaixa res.
def nvme_wear_only?(health)
  return false unless health
  return false unless health['critical_warning'].to_i == NVME_CW_RELIABILITY
  return false unless health['media_errors'].to_i.zero?
  return false unless health['percentage_used'].to_i >= 100

  spare, spare_th = health['available_spare'], health['available_spare_threshold']
  !spare.nil? && !spare_th.nil? && spare > spare_th
end

# Classifica una lectura de `smartctl -j -H -A -l selftest` d'un disc: retorna
# els problemes (CRITICAL), els avisos (WARNING) i els comptadors de vida, que
# el bucle principal compara amb la mostra anterior. A part del bucle per
# poder-lo provar amb lectures de discos reals (test_check_smart.rb).
def device_findings(d, label, warn_used)
  problems = []
  warns = []
  counters = {}

  health = d['nvme_smart_health_information_log']
  # Un NVMe només gastat aixeca el bit de fiabilitat i, amb ell,
  # `smart_status.passed=false`: les dues línies són el mateix avís.
  worn = nvme_wear_only?(health)
  problems << 'health FAILED' if d.dig('smart_status', 'passed') == false && !worn

  if health
    used = health['percentage_used'].to_i
    spare, spare_th = health['available_spare'], health['available_spare_threshold']
    if worn
      warns << "#{label}: #{used}% used, past rated endurance " \
               "(reliability_degraded, spare #{spare}%, 0 media errors)"
    else
      cw = health['critical_warning'].to_i
      problems << format('critical_warning=0x%02x', cw) if cw != 0
      problems << "available_spare #{spare}% < #{spare_th}%" if spare && spare_th && spare < spare_th
      warns << "#{label}: #{used}% used" if used >= warn_used
    end
    counters['media_errors'] = health['media_errors'].to_i
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

  [problems, warns, counters]
end

# (def clàssic: db1, ha i cleopatra encara corren ruby 2.7)
def plural(n, word)
  "#{n} #{word}#{'s' unless n == 1}"
end

# El cos del plugin només corre com a plugin: així `test_check_smart.rb` se'l
# pot fer `require_relative` i provar la classificació sense que el check
# s'executi (ni contra els discos de qui fa les proves).
return unless __FILE__ == $PROGRAM_NAME

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

unless ENV['PATH'].split(':').any? { |dir| File.executable?(File.join(dir, 'smartctl')) }
  puts 'SMART UNKNOWN - smartctl not found (install smartmontools)'
  exit 3
end

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

  problems, dev_warn, counters = device_findings(d, label, warn_used)

  # creixement dels comptadors dins la finestra (la primera mostra és la base)
  key = d['serial_number'] || "#{dev['name']} #{dev['type']}"
  samples = (state[key] || []).select { |t, _| t.is_a?(Integer) && t >= cutoff }
  samples << [now, counters]
  state[key] = samples
  base = samples.first[1] || {}
  counters.each do |name, val|
    grew = val - base[name].to_i
    if grew > 0 && base.key?(name)
      dev_warn << "#{label}: #{name} +#{grew} in #{window_h.round}h (now #{val})"
    elsif val > 0
      notes << "#{label} #{name}=#{val}"
    end
  end

  if problems.any?
    crit << "#{label}: #{problems.join(', ')}"
  elsif dev_warn.empty?
    # un disc amb WARNING no és un "other disk OK": un host amb dos discos,
    # tots dos avisats, es comptava ell mateix com a "2 other disks OK".
    ok_names << label
  end
  warn.concat(dev_warn)
end

File.write(state_file, JSON.generate(state)) rescue nil

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
