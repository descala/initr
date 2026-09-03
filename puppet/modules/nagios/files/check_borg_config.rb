#!/usr/bin/ruby
#
# check_borg_config.rb — plugin Nagios: valida la config del borg_backup.sh
#
# El bug conegut d'initr (BorgBackupController#configure) pot deixar
# REPOSITORY="" o BORG_PASSPHRASE="" al script que desplega Puppet: el
# backup falla cada nit amb "Invalid location format" (bk 15–25/07/2026,
# sapigration 30/07/2026). Aquest check ho detecta el mateix matí en lloc
# de deixar-ho degotar dies amb un CRITICAL de text enganyós.
#
# Ús: check_borg_config.rb [FITXER]   (defecte /usr/local/sbin/borg_backup.sh)

path = ARGV[0] || '/usr/local/sbin/borg_backup.sh'
begin
  content = File.read(path)
rescue Errno::ENOENT
  puts "BORG CONFIG UNKNOWN - #{path} not found"
  exit 3
end

repo = content[/^REPOSITORY=["']?([^"'\n]*)/, 1]
pass = content[/^(?:export\s+)?BORG_PASSPHRASE=["']?([^"'\n]*)/, 1]

empty = []
empty << 'REPOSITORY' if repo.nil? || repo.empty?
empty << 'BORG_PASSPHRASE' if pass.nil? || pass.empty?

if empty.any?
  puts "BORG CONFIG CRITICAL - empty #{empty.join(' and ')} in #{path} (initr node config?)"
  exit 2
end
puts "BORG CONFIG OK - repository #{repo}"
exit 0
