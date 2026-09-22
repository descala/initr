#!/usr/bin/ruby
#
# check_letsencrypt.rb — plugin Nagios: els certificats que el web server serveix
# de debò, caduquen? i certbot els renovarà?
#
# A una granja de hosting compartit els certificats de Let's Encrypt que no es
# renoven només es descobreixen quan un client avisa (tres casos entre 08 i
# 09/2026). Els dos senyals que ja hi ha no serveixen:
#
#  - `certbot.service` acaba en FAILURE a cada execució a la majoria de hosts,
#    per lineages morts (el domini ha marxat, el compte ACME v1 ja no existeix)
#    que ningú neteja. Vigilar-lo és estar sempre en vermell.
#  - Mirar la caducitat de tot /etc/letsencrypt/live/ tampoc: un host vell pot
#    tenir dotzenes de directoris orfes caducats fa anys que cap vhost fa servir.
#
# Aquest check mira-ho des del web server: pren els fitxers de certificat que
# nginx (`nginx -T`, directiva ssl_certificate) o Apache (`apache2ctl -S` →
# fitxers de vhost → SSLCertificateFile) tenen carregats ara, i per a cadascun:
#
#  - dies fins a caducar: <= --crit → CRITICAL, <= --warn → WARNING, caducat →
#    CRITICAL. certbot renova quan queden 30 dies, així que un cert servit amb
#    25 o menys ja porta ≥ 4 dies (8 intents) fallant: no és transitori.
#    Llindars pensats per a certs de 90 dies.
#  - si viu a live/<lineage>/ i no existeix renewal/<lineage>.conf → WARNING
#    ja avui: certbot no sap que existeix i no el renovarà mai (passa quan es
#    copia live/ d'un servidor a l'altre sense el renewal conf).
#  - fitxer que no hi és o no es pot llegir → CRITICAL.
#
# I dos senyals de context: `certbot.timer` parat → WARNING (si no, ens
# n'assabentaríem 30 dies més tard per la caducitat), i els lineages amb
# renewal conf que cap vhost fa servir, amb quants estan fallant la renovació
# (caducats o sota els 30 dies). Aquests últims NO canvien l'estat: no trenquen
# cap web, però són el que fa fallar certbot.service i el que cal netejar
# (`certbot delete --cert-name X`) perquè el journal torni a dir alguna cosa.
#
# Els certs que no són de Let's Encrypt (snakeoil per defecte, comprats)
# passen la comprovació de caducitat i res més.
#
# Sense DNS a propòsit: un vhost amb el cert caducat el domini del qual ja no
# apunta aquí surt igualment com a CRITICAL. És brossa que cal treure
# (a2dissite / esborrar el vhost), i mentre hi sigui el check no és verd.
#
# El cron de root corre amb PATH=/usr/bin:/bin: nginx, apache2ctl i systemctl
# són a sbin, s'afegeix el PATH aquí.
#
# ⚠ Ha de córrer amb el Ruby de stretch (2.3) i buster (2.5): res de `match?`,
# `Array#sum`, `Dir.children`, `then`, endless methods ni `filter_map`; i res
# de `File.exists?`, que no hi és a 3.3 (trixie). Provar amb `ruby -c` a un
# host vell abans de desplegar.
#
# Ús: check_letsencrypt.rb [-w DIES] [-c DIES] [--le-dir DIR] [--no-timer]
#   (defectes: -w 25 -c 14 --le-dir /etc/letsencrypt)

require 'optparse'
require 'openssl'

LIST_MAX = 6

# El cron corre sense LANG, o sigui amb US-ASCII per defecte, i els vhosts
# porten comentaris amb accents (alguns en latin-1). Un regex sobre una cadena
# amb bytes invàlids peta amb ArgumentError; sobre bytes crus no peta mai, i
# els noms de fitxer que en traiem són ASCII.
def binary(text)
  text.dup.force_encoding(Encoding::BINARY)
end

# ---------------------------------------------------------------- nginx

# Fitxers de certificat que nginx carrega, a partir del volcat de `nginx -T`
# (o del text dels fitxers de configuració, que és el mateix format).
# Ignora comentaris, ssl_certificate_key i valors amb variables; resol les
# rutes relatives contra el directori de configuració, com fa nginx.
def nginx_cert_paths(dump, conf_dir = '/etc/nginx')
  paths = []
  binary(dump).each_line do |line|
    m = line.match(/^\s*ssl_certificate\s+([^;\s]+)\s*;/)
    next unless m
    path = m[1].force_encoding(Encoding::UTF_8)
    next if path.start_with?('$')
    path = File.join(conf_dir, path) unless path.start_with?('/')
    paths << path unless paths.include?(path)
  end
  paths
end

# ---------------------------------------------------------------- apache

# Fitxers de vhost que Apache té carregats, dels "(fitxer:línia)" que
# `apache2ctl -S` escriu al costat de cada vhost.
def apache_vhost_files(status)
  files = []
  status.scan(/\((\/[^():]+):\d+\)/) do |(path)|
    files << path unless files.include?(path)
  end
  files
end

# SSLCertificateFile de cada fitxer de vhost (segueix els symlinks de
# sites-enabled perquè llegeix el fitxer, no el directori).
def apache_cert_paths(files, server_root = '/etc/apache2')
  paths = []
  files.each do |file|
    next unless File.file?(file)
    binary(File.binread(file)).each_line do |line|
      m = line.match(/^\s*SSLCertificateFile\s+"?([^"\s]+)"?/)
      next unless m
      path = m[1].force_encoding(Encoding::UTF_8)
      path = File.join(server_root, path) unless path.start_with?('/')
      paths << path unless paths.include?(path)
    end
  end
  paths
end

# ---------------------------------------------------------------- certbot

# Nom del lineage (live/<nom>/...) si el fitxer és de certbot; nil si no.
def lineage_of(path, le_dir)
  m = path.match(%r{\A#{Regexp.escape(le_dir)}/live/([^/]+)/[^/]+\z})
  m && m[1]
end

def days_left(pem_path, now)
  cert = OpenSSL::X509::Certificate.new(File.read(pem_path))
  ((cert.not_after - now) / 86_400).floor
end

# Un registre per fitxer servit: :label (lineage o nom del fitxer), :days
# (nil si no s'ha pogut llegir), :conf (té renewal conf), :error.
def inspect_certs(paths, le_dir:, now: Time.now)
  paths.map do |path|
    lineage = lineage_of(path, le_dir)
    rec = { path: path, lineage: lineage, label: lineage || File.basename(path),
            days: nil, conf: false, error: nil }
    rec[:conf] = lineage.nil? || File.file?(File.join(le_dir, 'renewal', "#{lineage}.conf"))
    if !File.file?(path)
      rec[:error] = 'not found'
    else
      begin
        rec[:days] = days_left(path, now)
      rescue OpenSSL::X509::CertificateError, ArgumentError
        rec[:error] = 'unreadable'
      end
    end
    rec
  end
end

# Lineages amb renewal conf que cap vhost serveix, amb els dies que li queden
# al seu cert (nil si ni cert té).
def unused_lineages(served_lineages, le_dir:, now: Time.now)
  Dir.glob(File.join(le_dir, 'renewal', '*.conf')).sort.map do |conf|
    name = File.basename(conf, '.conf')
    next if served_lineages.include?(name)
    pem = File.join(le_dir, 'live', name, 'cert.pem')
    days = begin
      File.file?(pem) ? days_left(pem, now) : nil
    rescue OpenSSL::X509::CertificateError, ArgumentError
      nil
    end
    { name: name, days: days }
  end.compact
end

# ---------------------------------------------------------------- verdict

def fmt_days(rec)
  rec[:days].nil? ? 'no cert' : "#{rec[:days]}d"
end

def listing(items)
  shown = items.first(LIST_MAX)
  rest = items.size - shown.size
  shown.join(', ') + (rest > 0 ? ", +#{rest} more" : '')
end

# Retorna [codi de sortida, línia de sortida]. Cap `*`, `?`, `[` ni salt de
# línia a la sortida: nsca_wrapper la passa per `echo $output` sense cometes.
def evaluate(certs, unused, warn:, crit:, timer_active:, notes: [])
  return [3, 'LETSENCRYPT UNKNOWN - no served certificates found (no nginx/apache ssl_certificate directives)'] if certs.empty?

  broken   = certs.select { |c| c[:error] }
  readable = certs - broken
  expired  = readable.select { |c| c[:days] < 0 }.sort_by { |c| c[:days] }
  expiring = readable.select { |c| c[:days] >= 0 && c[:days] <= warn }.sort_by { |c| c[:days] }
  # Només els de certbot: un cert comprat o el snakeoil no tenen renewal conf.
  noconf   = readable.select { |c| c[:days] >= 0 && c[:lineage] && !c[:conf] }.sort_by { |c| c[:days] }
  healthy  = readable - expired - expiring
  # certbot renova a 30 dies: un lineage no servit amb menys ja està fallant.
  failing  = unused.select { |u| u[:days].nil? || u[:days] < 30 }.sort_by { |u| u[:days] || 1_000_000 }

  state = 0
  parts = []
  unless broken.empty?
    state = 2
    parts << "#{broken.size} unreadable: #{listing(broken.map { |c| "#{c[:label]} (#{c[:error]})" })}"
  end
  unless expired.empty?
    state = 2
    parts << "#{expired.size} expired: #{listing(expired.map { |c| "#{c[:label]} #{fmt_days(c)}" })}"
  end
  unless expiring.empty?
    state = [state, expiring.any? { |c| c[:days] <= crit } ? 2 : 1].max
    parts << "#{expiring.size} expiring: #{listing(expiring.map { |c| "#{c[:label]} #{fmt_days(c)}" })}"
  end
  unless noconf.empty?
    state = [state, 1].max
    parts << "#{noconf.size} without renewal conf: #{listing(noconf.map { |c| "#{c[:label]} #{fmt_days(c)}" })}"
  end
  unless timer_active
    state = [state, 1].max
    parts << 'certbot.timer not active'
  end
  notes.each do |n|
    state = [state, 1].max
    parts << n
  end
  min_days = readable.map { |c| c[:days] }.min
  healthy_min = healthy.map { |c| c[:days] }.min
  parts << "#{healthy.size} served certs OK" + (healthy_min ? " (min #{healthy_min}d)" : '')
  unless unused.empty?
    info = "#{unused.size} unused lineages"
    info << ", #{failing.size} failing renewal: #{listing(failing.map { |u| "#{u[:name]} #{fmt_days(u)}" })}" unless failing.empty?
    parts << info
  end

  label = %w[OK WARNING CRITICAL][state]
  perf = "served=#{certs.size} expired=#{expired.size} expiring=#{expiring.size} noconf=#{noconf.size} " \
         "unused_failing=#{failing.size} min_days=#{min_days.nil? ? 'U' : min_days}"
  [state, "LETSENCRYPT #{label} - #{parts.join('; ')} | #{perf}".tr("\n*?[", '    ').squeeze(' ')]
end

# ---------------------------------------------------------------- main

# `return` a nivell superior només existeix des de Ruby 2.4: amb 2.3 el test
# no podria fer `require` del plugin. D'aquí el bloc.
if __FILE__ == $PROGRAM_NAME

ENV['PATH'] = "/usr/sbin:/sbin:#{ENV['PATH']}"

warn_d = 25
crit_d = 14
le_dir = '/etc/letsencrypt'
check_timer = true
OptionParser.new do |o|
  o.on('-w DIES', Integer) { |v| warn_d = v }
  o.on('-c DIES', Integer) { |v| crit_d = v }
  o.on('--le-dir DIR') { |v| le_dir = v }
  o.on('--no-timer') { check_timer = false }
end.parse!

def which(bin)
  ENV['PATH'].split(':').any? { |d| File.executable?(File.join(d, bin)) }
end

paths = []
notes = []

if File.file?('/etc/nginx/nginx.conf') && which('nginx')
  dump = `nginx -T 2>/dev/null`
  if $?.success? && !dump.empty?
    paths.concat(nginx_cert_paths(dump))
  else
    # nginx -t falla (un cert que no hi és, una directiva trencada): el que
    # corre és la config anterior, i el reload que faria certbot fallaria.
    notes << 'nginx -t fails, parsed sites-enabled'
    files = Dir.glob('/etc/nginx/sites-enabled/*') + Dir.glob('/etc/nginx/conf.d/*.conf') +
            Dir.glob('/etc/nginx/snippets/*')
    text = files.select { |f| File.file?(f) }.map { |f| File.read(f) }.join("\n")
    paths.concat(nginx_cert_paths(text))
  end
end

if File.file?('/etc/apache2/apache2.conf') && which('apache2ctl')
  status = `apache2ctl -S 2>/dev/null`
  files = apache_vhost_files(status)
  if $?.success? && !files.empty?
    paths.concat(apache_cert_paths(files))
  else
    notes << 'apache2ctl -S fails, parsed sites-enabled'
    paths.concat(apache_cert_paths(Dir.glob('/etc/apache2/sites-enabled/*.conf')))
  end
end

paths.uniq!
certs = inspect_certs(paths, le_dir: le_dir)
served = certs.map { |c| c[:lineage] }.compact
unused = unused_lineages(served, le_dir: le_dir)

timer_active = true
if check_timer && File.directory?(File.join(le_dir, 'renewal')) && which('systemctl')
  timer_active = `systemctl is-active certbot.timer 2>/dev/null`.strip == 'active'
end

state, line = evaluate(certs, unused, warn: warn_d, crit: crit_d, timer_active: timer_active, notes: notes)
puts line
exit state

end
