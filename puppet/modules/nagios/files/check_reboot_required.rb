#!/usr/bin/ruby
#
# check_reboot_required.rb — plugin Nagios: reinici pendent i kernel obsolet
#
# `unattended-upgrades` instal·la els kernels de seguretat, però ningú no
# reinicia: el pegat és al disc i no al kernel que corre, i un check
# d'actualitzacions pendents dirà OK tota l'estona mentre això passa.
#
# Dues mesures, perquè cap de les dues sola no serveix:
#
#  - **Antiguitat del flag** `/var/run/reboot-required`. És la resposta a
#    "quants dies fa que tens el reinici pendent", però el fitxer es reescriu a
#    cada kernel nou (i viu a /run, o sigui que el reinici el neteja): un host
#    que no reinicia mai però va instal·lant kernels el pot tenir sempre jove.
#  - **Uptime amb un kernel més nou instal·lat** (`-u`): tanca aquell forat. Si
#    hi ha un kernel més nou al disc, el que corre ja és obsolet ara mateix, i
#    l'uptime diu des de quan com a molt.
#
# Els llindars són política de reinicis, no mecànica del plugin: `-w` i `-c`
# van sobre els dies de reinici pendent i `-u` sobre l'uptime amb un kernel més
# nou al disc. Pujar-los o baixar-los per host no demana tocar el plugin.
#
# Sense cap binari extern (llegeix /proc i /boot): el cron de root corre amb
# PATH=/usr/bin:/bin i així no depèn de res.
#
# ⚠ Debian bullseye porta Ruby 2.7 i trixie 3.3: res d'endless methods
# (`def f(x) = ...`), que a 2.7 són syntax error, ni de `File.exists?`, que ja
# no hi és a 3.3. Provar-ho a totes dues abans de desplegar.
#
# Ús: check_reboot_required.rb [-w DIES] [-c DIES] [-u DIES]
#   (defectes: -w 14 -c 45 -u 180)

require 'optparse'

warn_d = 14
crit_d = 45
uptime_crit_d = 180
OptionParser.new do |o|
  o.on('-w DIES', Integer) { |v| warn_d = v }
  o.on('-c DIES', Integer) { |v| crit_d = v }
  o.on('-u DIES', Integer) { |v| uptime_crit_d = v }
end.parse!

FLAG = '/var/run/reboot-required'
PKGS = '/var/run/reboot-required.pkgs'

# Ordena versions de kernel pels números, no com a cadena: 6.12.88 < 6.12.100
# (com a text seria al contrari), 6.1.0-28 < 6.1.0-52, 6.12.90+deb13.1 <
# 6.12.107+deb13. El sufix de sabor (-amd64, -cloud-amd64, -generic) no porta
# números i no hi pesa.
def version_key(v)
  v.scan(/\d+/).map(&:to_i)
end

running = File.read('/proc/sys/kernel/osrelease').strip rescue nil
unless running
  puts 'REBOOT UNKNOWN - cannot read /proc/sys/kernel/osrelease'
  exit 3
end
uptime_d = File.read('/proc/uptime').split.first.to_f / 86_400.0 rescue 0.0

# Kernels instal·lats. Si /boot no en té cap (algun cloud image porta el kernel
# fora de /boot) només es pot anar pel flag.
kernels = Dir['/boot/vmlinuz-*'].to_h { |p| [File.basename(p).sub('vmlinuz-', ''), p] }
newest = kernels.keys.max_by { |k| version_key(k) }
stale_kernel = newest && (version_key(newest) <=> version_key(running)) == 1

flagged = File.exist?(FLAG)
pending_d = if flagged
              (Time.now - File.mtime(FLAG)) / 86_400.0
            elsif stale_kernel
              (Time.now - File.mtime(kernels[newest])) / 86_400.0
            end

if !flagged && !stale_kernel
  puts "REBOOT OK - running #{running}, no newer kernel installed, no reboot pending"
  exit 0
end

# Què demana el reinici (kernels o libc/dbus/systemd): la primera línia és
# l'única que travessa nsca_wrapper, així que només el compte i un parell.
pkgs = File.readlines(PKGS).map(&:strip).reject(&:empty?).uniq rescue []
what = if pkgs.empty?
         ''
       else
         " [#{pkgs.first(2).join(', ')}#{pkgs.size > 2 ? ", +#{pkgs.size - 2}" : ''}]"
       end
kernel_part = if stale_kernel
                "running #{running}, newest installed #{newest}"
              else
                "running #{running} (newest installed)"
              end
msg = "#{kernel_part}, pending #{pending_d.round}d, up #{uptime_d.round}d#{what}"

if pending_d >= crit_d
  puts "REBOOT CRITICAL - #{msg}"
  exit 2
elsif stale_kernel && uptime_d >= uptime_crit_d
  puts "REBOOT CRITICAL - #{msg} (newer kernel on disk and never rebooted)"
  exit 2
elsif pending_d >= warn_d
  puts "REBOOT WARNING - #{msg}"
  exit 1
else
  puts "REBOOT OK - #{msg}"
  exit 0
end
