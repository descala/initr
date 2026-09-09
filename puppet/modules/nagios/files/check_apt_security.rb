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
#  - **Dona a u-u la seva finestra sencera.** `apt-daily-upgrade.timer` és
#    `OnCalendar 6:00` amb `RandomizedDelaySec=60m`, o sigui que un paquet que
#    apareix a les 17:00 no és feina de ningú fins demà a les 7. Per això el
#    check no compta hores des que el veu sinó **passades de u-u
#    sobreviscudes** (`upgrade-stamp`, que només avança quan la passada de u-u
#    de la finestra acaba bé): mentre u-u no hagi corregut des que veiem el paquet
#    l'estat és OK amb el paquet escrit a la línia de sortida, WARNING quan
#    n'ha sobreviscut una passada i CRITICAL quan n'ha sobreviscut
#    `--miss-crit` (2). Avisar al primer cop de vista volia dir avisar 13 h
#    per un paquet que u-u instal·lava sol l'endemà al matí: dues
#    notificacions per correu a tothom qui hi és, i algú entrant al host a fer
#    `apt upgrade` a mà per una cosa que ja estava resolta.
#  - **Comprova qui li dona la feina.** Tanta mà esquerra només val si u-u
#    corre de veritat, o sigui que el stamp de u-u té els mateixos llindars de
#    vellesa que el de l'update (`--stale-warn`/`--stale-crit`), un
#    `APT::Periodic::Unattended-Upgrade "0"` (posar un hold així és el que es
#    fa per aturar una catch-up de mesos) treu tota la mà esquerra, i
#    `--grace-crit` segueix sent el sostre per si el stamp no avança mai.
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
#                           [--grace-warn HORES] [--grace-crit HORES]
#                           [--miss-crit PASSADES] [-s FITXER]
#   (defectes: 3, 7, 26, 48, 2, /var/tmp/check_apt_security.json;
#    cadència: horària, freshness 4500)
#
# `--stale-warn` és 3 dies perquè un host sa hi arriba: `apt-daily.timer` porta
# `RandomizedDelaySec=12h` i l'update només corre si el stamp té més d'un dia,
# o sigui que ~36 h entre refrescos és normal. `--grace-warn` és 26 h perquè la
# finestra de u-u es tanca a les 7 i l'interval és d'un dia: passades 26 h
# sense cap passada de u-u, se n'ha saltat una. `--grace-crit` és el sostre per
# si el stamp de u-u no avança gens.
#
# Límits coneguts: un paquet retingut que necessiti dependències noves no surt
# a `apt-get -s upgrade` (igual que a check_apt); i si un repo té
# `Acquire::Check-Valid-Until "false"` aquest check el comptarà com a caducat
# tot i que apt se'l salti — que és precisament el que volem veure.
#
# ⚠ Debian bullseye porta Ruby 2.7 i trixie 3.3: res d'endless methods
# (`def f(x) = ...`), que a 2.7 són syntax error, ni de `File.exists?`, que ja
# no hi és a 3.3. Provar-ho a totes dues abans de desplegar
# (`test_check_apt_security.rb` d'aquest directori hi corre tal qual).

require 'optparse'
require 'json'
require 'time'

UPDATE_STAMP = '/var/lib/apt/periodic/update-stamp'
# Només aquest stamp: `apt.systemd.daily` l'escriu quan l'`unattended-upgrade`
# de la finestra ha sortit amb 0 (línies 494-496), o sigui que vol dir "u-u ha
# tingut la seva passada i ha anat bé". El veí `unattended-upgrades-stamp`
# l'escriu el binari de u-u a cada invocació, **--dry-run inclòs**
# (`write_stamp_file()`): comptar-lo faria que un `unattended-upgrade
# --dry-run` de triatge —el primer que fa qualsevol que investigui aquest
# check— es comptés com una passada i fabriqués l'escalada que anava a mirar
# (comprovat: el dry-run movia el stamp 12 h endavant).
UU_STAMP = '/var/lib/apt/periodic/upgrade-stamp'
APT = 'apt-get -o Debug::NoLocking=true'

def pkg_list(pkgs, max = 4)
  pkgs.first(max).join(' ') + (pkgs.size > max ? " +#{pkgs.size - max}" : '')
end

def days_since(path)
  File.exist?(path) ? (Time.now - File.mtime(path)) / 86_400.0 : nil
end

def age_s(days)
  days < 2 ? "#{(days * 24).round}h" : "#{days.round}d"
end

def oldest_age_s(pkgs, state, now)
  age_s(pkgs.map { |p| (now - state[p]['seen']) / 86_400.0 }.max)
end

# Les dues frases dels paquets pendents. Van igual a WARNING i a CRITICAL: la
# diferència entre els dos estats és un llindar, no un fenomen diferent.
def skipped_clause(pkgs, state, now, uu_when)
  passes = pkgs.map { |p| state[p]['misses'] }.max
  "#{pkgs.size} security update(s) pending #{oldest_age_s(pkgs, state, now)}, left behind by " \
    "#{passes} unattended-upgrades run#{'s' if passes > 1} (last #{uu_when}): #{pkg_list(pkgs.sort)}"
end

def stalled_clause(pkgs, state, now, uu_when)
  "#{pkgs.size} security update(s) pending #{oldest_age_s(pkgs, state, now)} with no " \
    "unattended-upgrades run since they appeared (last #{uu_when}): #{pkg_list(pkgs.sort)}"
end

# Interval de u-u en dies. 0 vol dir desactivat, i sense `20auto-upgrades` la
# clau no hi és (que és el mateix): aleshores esperar no arreglarà res.
def uu_interval_days
  `apt-config dump APT::Periodic::Unattended-Upgrade 2>/dev/null`[/"(\d+)"/, 1].to_i
end

# Estat per paquet: quan el vam veure per primer cop i quantes passades de u-u
# ha sobreviscut d'aleshores. Format:
#
#   {"pkg" => {"seen" => epoch, "uu" => epoch de l'última passada ja comptada,
#              "misses" => passades sobreviscudes}}
#
# Del format vell (només l'epoch de "seen") es conserva el "seen"; sense "uu",
# la primera passada de u-u posterior a "seen" es compta aquí mateix, o sigui
# que un paquet que abans era CRITICAL passa a WARNING i no a OK.
def apt_state(raw, security, now, uu_run)
  state = raw.each_with_object({}) do |(pkg, rec), h|
    next unless security.include?(pkg)

    rec = { 'seen' => rec } if rec.is_a?(Integer)
    next unless rec.is_a?(Hash) && rec['seen'].to_i.positive?

    # Res del fitxer no es dona per bo: és a /var/tmp i un valor rar no ha de
    # tombar el check (un `uu` no numèric petava a la comparació de sota).
    h[pkg] = { 'seen' => rec['seen'].to_i, 'misses' => rec['misses'].to_i,
               'uu' => (rec['uu'].is_a?(Integer) ? rec['uu'] : nil) }
  end
  security.each { |pkg| state[pkg] ||= { 'seen' => now, 'uu' => uu_run, 'misses' => 0 } }

  # Una passada sobreviscuda és un stamp de u-u que no havíem comptat i
  # posterior al primer cop que vam veure el paquet: u-u ha tingut la seva
  # finestra sencera i l'ha deixat igualment. Comparar contra el stamp ja
  # comptat és el que evita que els 24 checks horaris del dia la comptin 24
  # vegades.
  state.each_value do |rec|
    next unless uu_run && uu_run > rec['seen']
    next if rec['uu'] && uu_run <= rec['uu']

    rec['misses'] += 1
    rec['uu'] = uu_run
  end
  state
end

# Reparteix la culpa de cada paquet pendent. `opts`: :grace_warn_h,
# :grace_crit_h, :miss_crit, :uu_enabled.
def apt_buckets(security, state, now, opts)
  buckets = { skipped_crit: [], stalled_crit: [], skipped_warn: [], stalled_warn: [], waiting: [] }
  security.each do |pkg|
    rec = state[pkg]
    age_h = (now - rec['seen']) / 3600.0
    # La gravetat la decideix qualsevol dels dos llindars; `skipped` només
    # tria la frase, perquè "u-u ha corregut i l'ha deixat" i "de u-u no se'n
    # sap res" són dues coses diferents i el sostre horari pot disparar en
    # totes dues.
    skipped = rec['misses'].positive?
    key = if rec['misses'] >= opts[:miss_crit] || age_h >= opts[:grace_crit_h]
            skipped ? :skipped_crit : :stalled_crit
          elsif skipped || age_h >= opts[:grace_warn_h] || !opts[:uu_enabled]
            skipped ? :skipped_warn : :stalled_warn
          else
            :waiting
          end
    buckets[key] << pkg
  end
  buckets
end

# El cos del plugin només corre com a plugin: així `test_check_apt_security.rb`
# se'l pot fer `require_relative` i provar els dos mètodes de dalt sense que el
# check s'executi (ni contra l'apt de qui fa les proves).
return unless __FILE__ == $PROGRAM_NAME

stale_warn_d = 3
stale_crit_d = 7
grace_warn_h = 26
grace_crit_h = 48
miss_crit = 2
state_file = '/var/tmp/check_apt_security.json'
OptionParser.new do |o|
  o.on('--stale-warn DIES', Integer) { |v| stale_warn_d = v }
  o.on('--stale-crit DIES', Integer) { |v| stale_crit_d = v }
  o.on('--grace-warn HORES', Integer) { |v| grace_warn_h = v }
  o.on('--grace-crit HORES', Integer) { |v| grace_crit_h = v }
  o.on('--miss-crit PASSADES', Integer) { |v| miss_crit = v }
  o.on('-s FITXER') { |v| state_file = v }
end.parse!

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

# 4. I u-u? Tota la mà esquerra de la secció 6 es basa en que la seva finestra
#    arriba cada dia; si no arriba, això és el que cal dir, i no repartir-ne.
uu_days = uu_interval_days
uu_run = File.exist?(UU_STAMP) ? File.mtime(UU_STAMP).to_i : nil
uu_when = uu_run ? Time.at(uu_run).strftime('%d/%m %H:%M') : 'never'
if uu_days.zero?
  warn << 'unattended-upgrades is disabled (APT::Periodic::Unattended-Upgrade 0)'
else
  # Un interval més llarg d'un dia mou la finestra: no té sentit donar 26 h de
  # marge a un u-u que corre cada setmana.
  grace_warn_h = [grace_warn_h, uu_days * 24 + 2].max if uu_days > 1
  uu_d = days_since(UU_STAMP)
  if uu_d.nil?
    warn << 'no record of an unattended-upgrades run'
  elsif uu_d >= stale_crit_d
    crit << "unattended-upgrades has not run in #{age_s(uu_d)} (apt-daily-upgrade broken?)"
  elsif uu_d >= stale_warn_d
    warn << "unattended-upgrades has not run in #{age_s(uu_d)}"
  end
end

# 5. Pendents, separant seguretat de la resta i mirant d'on venen.
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

if never.any?
  crit << "unattended-upgrades can never install #{never.size} security update(s) " \
          "(other release, not in Origins-Pattern): #{pkg_list(never.sort)}"
end

# 6. Els que u-u sí que pot instal·lar: qui n'ha tingut l'oportunitat.
now = Time.now.to_i
state = apt_state((JSON.parse(File.read(state_file)) rescue {}), security, now, uu_run)
File.write(state_file, JSON.generate(state)) rescue nil
b = apt_buckets(security, state, now,
                { grace_warn_h: grace_warn_h, grace_crit_h: grace_crit_h,
                  miss_crit: miss_crit, uu_enabled: !uu_days.zero? })

crit << skipped_clause(b[:skipped_crit], state, now, uu_when) if b[:skipped_crit].any?
crit << stalled_clause(b[:stalled_crit], state, now, uu_when) if b[:stalled_crit].any?
warn << skipped_clause(b[:skipped_warn], state, now, uu_when) if b[:skipped_warn].any?
warn << stalled_clause(b[:stalled_warn], state, now, uu_when) if b[:stalled_warn].any?

# Els que encara esperen la seva finestra no són un estat, però han de sortir a
# la línia: és el que evita l'`apt upgrade` a mà. Si ja hi ha res a dir, només
# el comptador (l'output d'NSCA té 512 bytes).
lists = stale_d ? "lists #{age_s(stale_d)} old" : 'lists never updated'
tail = "(#{other} non-security pending, #{lists})"
waiting = if b[:waiting].empty?
            nil
          elsif crit.empty? && warn.empty?
            "#{b[:waiting].size} security update(s) waiting for the next unattended-upgrades " \
              "run (last #{uu_when}): #{pkg_list(b[:waiting].sort)}"
          else
            "#{b[:waiting].size} more waiting for the next unattended-upgrades run"
          end

if crit.any?
  puts "APT SECURITY CRITICAL - #{(crit + warn + [waiting]).compact.join('; ')} #{tail}"
  exit 2
elsif warn.any?
  puts "APT SECURITY WARNING - #{(warn + [waiting]).compact.join('; ')} #{tail}"
  exit 1
else
  puts "APT SECURITY OK - #{waiting || 'no security updates pending'} #{tail}"
  exit 0
end
