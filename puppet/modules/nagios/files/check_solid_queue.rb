#!/usr/bin/ruby
#
# check_solid_queue.rb — plugin Nagios: salut de la cua Solid Queue d'una app Rails
#
# Amb Solid Queue les feines viuen en una BD MySQL/MariaDB. Els dos modes de
# fallada són silenciosos: una feina fallida queda a
# `solid_queue_failed_executions` sense que ningú la miri, i una cua sense
# workers creix sense que res peti. Tres modes, un servei per mode:
#
#  - `failed`: quantes `failed_executions` hi ha. Política de cua buida
#    (w 1, c 10): cada fallada es tria i es resol o s'esborra.
#    El missatge diu les classes, que és el primer que es vol saber per triar.
#  - `backlog`: edat de la `ready_execution` més vella de cada cua. Una cua que
#    envelleix vol dir workers morts, massa pocs o una allau d'encuaments.
#    Les cues pausades (Mission Control) no avisen: pausar-les és una decisió.
#  - `processes`: el supervisor, el dispatcher i els workers amb heartbeat
#    recent. `-n` és el nombre de workers de `config/queue.yml`. Menys workers
#    és WARNING, menys de la meitat o cap supervisor o dispatcher és CRITICAL.
#    Una fila amb el heartbeat aturat (un worker mort per l'OOM que Solid Queue
#    encara no ha podat) és WARNING.
#
# Les credencials surten de l'stanza `b2brouter_queue` de `database.yml` de
# l'app (per això corre al host dels workers, com a root). La contrasenya passa
# a `mysql` per `MYSQL_PWD`, que només és visible a root i a l'usuari que la
# llança, i no a la línia d'ordres. Només fa SELECT.
#
# Rails desa els `datetime` en UTC (`default_timezone = :utc`): les edats es
# calculen contra `UTC_TIMESTAMP()`, no `NOW()`.
#
# Ús: check_solid_queue.rb -m failed    [-w 1]   [-c 10]
#     check_solid_queue.rb -m backlog   [-w 300] [-c 900]
#     check_solid_queue.rb -m processes -n WORKERS [-s 300]
#     [-f /var/www/app/capistrano/shared/config/database.yml] [-e production]
#   (`-e staging` per a un entorn on l'stanza és sota `staging:`)
#   (cadència */5, freshness 950)

require 'optparse'
require 'yaml'
require 'open3'

DATABASE_YML = '/var/www/app/capistrano/shared/config/database.yml'.freeze

def plural(n, word)
  "#{n} #{word}#{n == 1 ? '' : 's'}"
end

def nagios(code, msg)
  [code, "SOLID_QUEUE #{%w[OK WARNING CRITICAL UNKNOWN][code]} - #{msg}"]
end

# L'stanza de la cua dins de `production`. El fitxer de producció té
# `production: &pro` i `development: *pro`, o sigui que cal acceptar àlies.
def queue_config(text, rails_env = 'production')
  env = YAML.safe_load(text, aliases: true).fetch(rails_env)
  env.fetch('b2brouter_queue') { raise KeyError, "no b2brouter_queue stanza in #{rails_env}" }
end

# rows: [[class_name, count]], ja ordenades de més a menys
def failed_result(rows, warn:, crit:)
  total = rows.sum { |_, n| n }
  return nagios(0, plural(total, 'failed execution')) if total.zero?

  shown = rows.first(5).map { |klass, n| "#{klass} #{n}" }
  shown << "+#{rows.size - 5} classes" if rows.size > 5
  code = total >= crit ? 2 : (total >= warn ? 1 : 0)
  nagios(code, "#{plural(total, 'failed execution')} (#{shown.join(', ')})")
end

# rows: [[queue_name, edat de la més vella en segons, feines a punt]]
def backlog_result(rows, paused, warn:, crit:)
  active = rows.reject { |q, _, _| paused.include?(q) }
  tail = paused.empty? ? '' : " [paused: #{paused.join(' ')}]"
  return nagios(0, "0 ready jobs#{tail}") if active.empty?

  active = active.sort_by { |_, age, _| -age }
  late = active.select { |_, age, _| age >= warn }
  if late.empty?
    queue, age, = active.first
    ready = active.sum { |_, _, n| n }
    return nagios(0, "#{ready} ready in #{plural(active.size, 'queue')}, oldest #{age}s (#{queue})#{tail}")
  end

  code = late.first[1] >= crit ? 2 : 1
  nagios(code, late.map { |q, age, n| "#{q} oldest #{age}s (#{n} ready)" }.join(' | ') + tail)
end

# rows: [[kind, hostname, segons des de l'últim heartbeat]]
def processes_result(rows, expected_workers:, stale:)
  live = rows.select { |_, _, age| age <= stale }
  dead = rows.size - live.size
  kinds = live.map(&:first)
  workers = kinds.count('Worker')

  crit = []
  warn = []
  crit << 'no live supervisor' unless kinds.any? { |k| k.start_with?('Supervisor') }
  crit << 'no live dispatcher' unless kinds.include?('Dispatcher')
  if workers * 2 < expected_workers
    crit << "#{workers}/#{expected_workers} workers alive"
  elsif workers < expected_workers
    warn << "#{workers}/#{expected_workers} workers alive"
  end
  warn << "#{plural(dead, 'stale process')} (heartbeat > #{stale}s)" if dead.positive?

  return nagios(2, (crit + warn).join(' | ')) if crit.any?
  return nagios(1, warn.join(' | ')) if warn.any?

  nagios(0, "supervisor, dispatcher and #{workers}/#{expected_workers} workers alive")
end

# Arguments de `mysql` per a una consulta (-B -N: files separades per tabulador).
# El client MariaDB 11.x exigeix TLS per defecte i rebutja un servidor que no en
# té. L'app (mysql2) només en fa servir si l'stanza el configura: el check fa el
# mateix, o diria UNKNOWN on l'app funciona. La contrasenya va per MYSQL_PWD.
def mysql_argv(cfg, sql)
  tls = cfg.key?('ssl_mode') || cfg.key?('sslca')
  ['mysql', '-h', cfg['host'].to_s, '-u', cfg['username'].to_s, *(tls ? [] : ['--skip-ssl']),
   '--connect-timeout=10', '-B', '-N', '-e', sql, cfg['database'].to_s]
end

return unless __FILE__ == $PROGRAM_NAME

mode = nil
warn_t = nil
crit_t = nil
workers = nil
stale = 300
yml = DATABASE_YML
rails_env = 'production'
OptionParser.new do |o|
  o.on('-m MODE', %w[failed backlog processes]) { |v| mode = v }
  o.on('-w N', Integer) { |v| warn_t = v }
  o.on('-c N', Integer) { |v| crit_t = v }
  o.on('-n WORKERS', Integer) { |v| workers = v }
  o.on('-s SECONDS', Integer) { |v| stale = v }
  o.on('-f FILE') { |v| yml = v }
  o.on('-e RAILS_ENV') { |v| rails_env = v }
end.parse!

def finish(code, msg)
  puts msg # nsca_wrapper només envia la primera línia
  exit code
end

finish(*nagios(3, 'usage: -m failed|backlog|processes (processes needs -n WORKERS)')) if mode.nil? || (mode == 'processes' && workers.nil?)

begin
  cfg = queue_config(File.read(yml), rails_env)
rescue StandardError => e
  finish(*nagios(3, "#{yml}: #{e.message}"))
end

query = lambda do |sql|
  out, err, status = Open3.capture3({ 'MYSQL_PWD' => cfg['password'].to_s }, *mysql_argv(cfg, sql))
  finish(*nagios(3, "mysql: #{err.lines.first.to_s.strip}")) unless status.success?
  out.lines.map { |l| l.chomp.split("\t") }
end

case mode
when 'failed'
  rows = query.call(<<~SQL).map { |k, n| [k, n.to_i] }
    SELECT j.class_name, COUNT(*) FROM solid_queue_failed_executions f
      JOIN solid_queue_jobs j ON j.id = f.job_id GROUP BY j.class_name ORDER BY 2 DESC, 1
  SQL
  finish(*failed_result(rows, warn: warn_t || 1, crit: crit_t || 10))
when 'backlog'
  rows = query.call(<<~SQL).map { |q, age, n| [q, age.to_i, n.to_i] }
    SELECT queue_name, TIMESTAMPDIFF(SECOND, MIN(created_at), UTC_TIMESTAMP()), COUNT(*)
      FROM solid_queue_ready_executions GROUP BY queue_name
  SQL
  paused = query.call('SELECT queue_name FROM solid_queue_pauses ORDER BY 1').map(&:first)
  finish(*backlog_result(rows, paused, warn: warn_t || 300, crit: crit_t || 900))
when 'processes'
  rows = query.call(<<~SQL).map { |k, h, age| [k, h, age.to_i] }
    SELECT kind, hostname, TIMESTAMPDIFF(SECOND, last_heartbeat_at, UTC_TIMESTAMP()) FROM solid_queue_processes
  SQL
  finish(*processes_result(rows, expected_workers: workers, stale: stale))
end
