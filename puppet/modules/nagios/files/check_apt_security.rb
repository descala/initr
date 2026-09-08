#!/usr/bin/ruby
#
# check_apt_security.rb — plugin Nagios: actualitzacions de seguretat pendents,
# comptant amb unattended-upgrades
#
# Alternativa a `check_apt -u -o`. A una flota amb unattended-upgrades actiu,
# aquell avisa de coses que no són problemes i calla davant d'algunes que sí:
#
#  - **No fa `apt-get update`.** El `-u` vol dir cada host refrescant el mirall
#    a cada passada i, si topa amb el lock d'apt-daily, un CRITICAL que no
#    parla de seguretat. L'estat de les llistes surt del stamp
#    `/var/lib/apt/periodic/update-stamp`, que només avança quan l'`apt-get
#    update` d'apt-daily acaba bé.
#  - **Reparteix la culpa.** `apt-daily-upgrade.timer` és `OnCalendar 6:00` amb
#    `RandomizedDelaySec=60m`: un check que caigui dins d'aquella hora veurà
#    paquets que u-u instal·larà pocs minuts després. Per això és WARNING
#    mentre u-u no hagi tingut la seva finestra des que el paquet és visible
#    (el primer cop que el veiem, contra `/var/lib/apt/periodic/upgrade-stamp`)
#    i CRITICAL quan u-u ha corregut i l'ha deixat.
#  - **Cadència horària, no diària.** Amb un check diari, "des de quan el
#    veiem" pot anar 24 h tard i la comparació amb l'última passada de u-u no
#    vol dir res. És un requisit del disseny, no una preferència.
#  - **CRITICAL de seguida si el paquet ve d'un altre release**
#    (`Debian-Security:12/oldstable-security` a un host trixie): l'
#    `Origins-Pattern` de `50unattended-upgrades` està ancorat a
#    `${distro_codename}` i no hi encaixarà mai, o sigui que esperar no
#    arreglarà res.
#  - **Mira també per què no hi ha res pendent.** Un `Release` amb el
#    `Valid-Until` passat (el que passa quan una release surt de suport i
#    l'arxiu deixa de refrescar-lo) fa que apt rebutgi el repo sencer, i amb
#    l'`apt-get check` trencat no s'instal·la res. En tots dos casos check_apt
#    pot dir "0 critical updates" mentre el host es queda sense pegats en
#    silenci.
#
# Ús: check_apt_security.rb [--stale-warn DIES] [--stale-crit DIES]
#                           [--grace HORES] [-s FITXER]
#   (defectes: 3, 7, 48, /var/tmp/check_apt_security.json; cadència: horària,
#   freshness 4500)
#
# `--stale-warn` és 3 dies perquè un host sa hi arriba: `apt-daily.timer` porta
# `RandomizedDelaySec=12h` i l'update només corre si el stamp té més d'un dia,
# o sigui que ~36 h entre refrescos és normal. `--grace` és el sostre per si el
# stamp de u-u no avança gens: passades 48 h pendent, CRITICAL igualment.
#
# Límits coneguts: un paquet retingut que necessiti dependències noves no surt
# a `apt-get -s upgrade` (igual que a check_apt); i si un repo té
# `Acquire::Check-Valid-Until "false"` aquest check el comptarà com a caducat
# tot i que apt se'l salti — que és precisament el que volem veure.
#
# ⚠ Debian bullseye porta Ruby 2.7 i trixie 3.3: res d'endless methods
# (`def f(x) = ...`), que a 2.7 són syntax error, ni de `File.exists?`, que ja
# no hi és a 3.3. Provar-ho a totes dues abans de desplegar.

require 'optparse'
require 'json'
require 'time'

stale_warn_d = 3
stale_crit_d = 7
grace_h = 48
state_file = '/var/tmp/check_apt_security.json'
OptionParser.new do |o|
  o.on('--stale-warn DIES', Integer) { |v| stale_warn_d = v }
  o.on('--stale-crit DIES', Integer) { |v| stale_crit_d = v }
  o.on('--grace HORES', Integer) { |v| grace_h = v }
  o.on('-s FITXER') { |v| state_file = v }
end.parse!

UPDATE_STAMP = '/var/lib/apt/periodic/update-stamp'
UU_STAMPS = ['/var/lib/apt/periodic/upgrade-stamp',
             '/var/lib/apt/periodic/unattended-upgrades-stamp'].freeze
APT = 'apt-get -o Debug::NoLocking=true'

def pkg_list(pkgs, max = 4)
  pkgs.first(max).join(' ') + (pkgs.size > max ? " +#{pkgs.size - max}" : '')
end

def days_since(path)
  File.exist?(path) ? (Time.now - File.mtime(path)) / 86_400.0 : nil
end

def age_s(days)
  days < 1 ? "#{(days * 24).round}h" : "#{days.round}d"
end

version_id = File.read('/etc/os-release')[/^VERSION_ID="?([^"\n]+)"?/, 1] rescue nil

crit = []
warn = []

# 1. apt sencer? Amb dependències sense resoldre no s'instal·la res, i cap
#    altra comprovació té sentit si això falla.
check_out = `#{APT} check 2>&1`
case $?.exitstatus
when 0
  nil
when 127
  puts 'APT SECURITY UNKNOWN - apt-get not found'
  exit 3
else
  line = check_out.lines.grep(/^E:/).first || check_out.lines.last.to_s
  crit << "apt is broken: #{line.strip[0, 60]}"
end

# 2. Repos amb el Release caducat: l'arxiu ha deixat de refrescar-lo (fi de
#    suport) i apt els rebutja sencers, o sigui zero pegats des d'aquell dia.
expired = {}
(Dir['/var/lib/apt/lists/*_InRelease'] + Dir['/var/lib/apt/lists/*_Release']).each do |f|
  base = File.basename(f).sub(/_(In)?Release$/, '')
  next if expired.key?(base)

  head = File.open(f) { |io| io.read(8192) }.to_s
  until_s = head[/^Valid-Until:\s*(.+)$/, 1] or next
  valid_until = Time.parse(until_s) rescue next
  next if valid_until >= Time.now

  host, _, suite = base.partition('_dists_')
  expired[base] = ["#{host.split('_').first} #{suite.empty? ? base : suite}",
                   (Time.now - valid_until) / 86_400.0]
end
if expired.any?
  # Agrupats en una clàusula: un host pot tenir dos miralls del mateix repo i
  # repetir la frase menjava la línia (nsca_wrapper només envia la primera).
  names = expired.values.map(&:first).sort
  oldest = expired.values.map(&:last).max
  crit << "#{names.size} repo Release(s) expired #{age_s(oldest)} ago " \
          "(out of support?): #{names.join(', ')}"
end

# 3. Llistes fresques? El stamp només avança quan l'`apt-get update`
#    d'apt-daily acaba bé, o sigui que la seva antiguitat delata un
#    apt-daily.timer que ja no venç (queda armat, sense next elapse) i mesos
#    sense refrescar res.
stale_d = days_since(UPDATE_STAMP)
if stale_d.nil?
  warn << 'no record of a successful apt-get update (apt-daily never ran?)'
elsif stale_d >= stale_crit_d
  crit << "no successful apt-get update in #{age_s(stale_d)} (apt-daily broken?)"
elsif stale_d >= stale_warn_d
  warn << "no successful apt-get update in #{age_s(stale_d)}"
end

# 4. Pendents, separant seguretat de la resta i mirant d'on venen.
sim = `#{APT} -s -qq upgrade 2>/dev/null`
security = []   # u-u els pot instal·lar: mateix release que el host
never = []      # d'un altre release: l'Origins-Pattern no hi encaixa mai
other = 0
sim.each_line do |l|
  m = l.match(/^Inst (\S+) \[[^\]]*\] \((.*)\)/) or next
  pkg = m[1]
  detail = m[2].sub(/\s*\[[^\]]*\]\s*$/, '')          # treu [amd64] / [all]
  sources = detail.split(/\s+/, 2)[1].to_s.split(', ') # treu la versió nova
  sec = sources.map { |s| s.split(':', 2) }
               .map { |origin, rest| [origin.to_s, rest.to_s.split('/', 2)] }
               .detect { |origin, (_rel, suite)| origin =~ /-Security$/i || suite.to_s.include?('-security') }
  if sec.nil?
    other += 1
  elsif version_id && sec[1][0] != version_id
    never << pkg
  else
    security << pkg
  end
end

# 5. Estat: quan hem vist per primer cop cada paquet de seguretat pendent.
state = JSON.parse(File.read(state_file)) rescue {}
state = {} unless state.is_a?(Hash)
now = Time.now.to_i
(security + never).each { |p| state[p] ||= now }
state.select! { |p, _| security.include?(p) || never.include?(p) }
File.write(state_file, JSON.generate(state)) rescue nil

if never.any?
  crit << "unattended-upgrades can never install #{never.size} security update(s) " \
          "(other release, not in Origins-Pattern): #{pkg_list(never.sort)}"
end

if security.any?
  uu_run = UU_STAMPS.map { |s| File.exist?(s) ? File.mtime(s).to_i : nil }.compact.max
  overdue, fresh = security.partition do |p|
    seen = state[p].to_i
    (uu_run && seen < uu_run) || (now - seen) >= grace_h * 3600
  end
  if overdue.any?
    when_s = uu_run ? Time.at(uu_run).strftime('%d/%m %H:%M') : 'never'
    crit << "#{overdue.size} security update(s) left behind by unattended-upgrades " \
            "(last run #{when_s}): #{pkg_list(overdue.sort)}"
  end
  if fresh.any?
    warn << "#{fresh.size} security update(s) pending, unattended-upgrades has not " \
            "run since they appeared: #{pkg_list(fresh.sort)}"
  end
end

lists = stale_d ? "lists #{age_s(stale_d)} old" : 'lists never updated'
tail = "(#{other} non-security pending, #{lists})"

if crit.any?
  puts "APT SECURITY CRITICAL - #{(crit + warn).join('; ')} #{tail}"
  exit 2
elsif warn.any?
  puts "APT SECURITY WARNING - #{warn.join('; ')} #{tail}"
  exit 1
else
  puts "APT SECURITY OK - no security updates pending #{tail}"
  exit 0
end
