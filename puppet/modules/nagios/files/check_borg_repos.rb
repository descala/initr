#!/usr/bin/ruby
#
# check_borg_repos.rb — plugin Nagios pel costat repositori (bk3)
#
# Per cada /srv/backups/*/repo comprova:
#   - frescor: mtime més nou dels index.*/hints.* del repo (s'actualitzen a
#     cada transacció borg). No obre el repo: no cal cap passphrase.
#   - cobertura offsite: que el FQDN del repo surti com a argument d'una
#     línia de /etc/cron.d/borg-s3-sync (la
#     llista és hardcoded; els repos nous no s'hi afegeixen sols — el de
#     sapigration i el de bk hi faltaven el 07/2026).
#
# Complementa el check client-side borg_backup_<host>: aquest veu els repos
# que existeixen encara que el client hagi perdut la config sencera.
#
# Ús: check_borg_repos.rb [-d DIR] [-w HORES] [-c HORES] [--s3-cron FITXER|skip]
#   (defectes: -d /srv/backups -w 30 -c 75, s3-cron /etc/cron.d/borg-s3-sync)

require 'optparse'

base = '/srv/backups'
warn_h = 30
crit_h = 75
s3_cron = '/etc/cron.d/borg-s3-sync'
OptionParser.new do |o|
  o.on('-d DIR') { |v| base = v }
  o.on('-w HORES', Integer) { |v| warn_h = v }
  o.on('-c HORES', Integer) { |v| crit_h = v }
  o.on('--s3-cron FITXER') { |v| s3_cron = v }
end.parse!

repos = Dir.glob(File.join(base, '*', 'repo')).sort
if repos.empty?
  puts "BORG REPOS UNKNOWN - no repos under #{base}"
  exit 3
end

now = Time.now
stale_crit = []
stale_warn = []
missing_s3 = []
s3_list = s3_cron == 'skip' ? nil : (File.read(s3_cron) rescue nil)

repos.each do |repo|
  name = File.basename(File.dirname(repo))
  newest = Dir.glob(File.join(repo, '{index,hints}.*'))
              .filter_map { |f| File.mtime(f) rescue nil }.max
  newest ||= (File.mtime(repo) rescue now) # repo buit/nou: també ha d'avisar
  age_h = ((now - newest) / 3600).round(1)
  if age_h >= crit_h
    stale_crit << "#{name} (#{age_h}h)"
  elsif age_h >= warn_h
    stale_warn << "#{name} (#{age_h}h)"
  end
  # token sencer: el cron passa el FQDN com a argument; `bk` no ha de casar amb `bk2`
  if s3_list && !s3_list.split.include?(name)
    missing_s3 << name
  end
end

problems = []
problems << "stale: #{(stale_crit + stale_warn).join(', ')}" if stale_crit.any? || stale_warn.any?
problems << "not in s3 sync: #{missing_s3.join(', ')}" if missing_s3.any?
problems << "#{s3_cron} unreadable" if s3_list.nil? && s3_cron != 'skip'

if stale_crit.any?
  puts "BORG REPOS CRITICAL - #{problems.join('; ')} (#{repos.size} repos)"
  exit 2
elsif problems.any?
  puts "BORG REPOS WARNING - #{problems.join('; ')} (#{repos.size} repos)"
  exit 1
else
  puts "BORG REPOS OK - #{repos.size} repos fresh (<#{warn_h}h) and in s3 sync"
  exit 0
end
