#!/usr/bin/env ruby

require "yaml"
require "fileutils"
require 'net/smtp'

class Copiador

  # constructor. si no li passem els camps els agafa del fitxer de configuracio.
  def initialize(settings=nil, origen=nil, desti=nil, bdays=nil, fs=nil)

    return if settings.nil?

    @Settings=settings
    @lockfile = File.join("/var/lock/copiador",File.basename(settings))

    # recuperem les dades del fitxer de configuracio
    s=recupera_settings

    @opcions = ""

    # fitxer de logs
    @log = s['log']

    # fitxer d'exculdes
    @exclude = s['exclude']

    # mostrar missatges de debug?
    @debug = s['debug']

    # mostrar nomes els fitxers que es copiaran, pero no fer res
    @dryrun = s['dryrun']

    # d'on volem fer copia
    @origen = origen || s['origen']
    @origen = @origen + '/'

    # a on la volem fer
    @desti = desti || s['desti']

    # on desar l'historic
    @historic = s['historic'].nil? ? "#{@desti}/../" : s['historic']

    # dies d'historic
    @bdays = (s['bdays'].class == Fixnum)? s['bdays'] : nil
    @bdays = (bdays.class == Fixnum)? bdays : @bdays
    if @bdays.nil?
      escriu_log "[ATENCIO] bdays no es enter, per defecte seran 4"
      @bdays = 4
    end

    # directori on guardar els backups
    @backupDir = "\"" + @historic + "/`date +%Y-%m-%d/%H-%M-%S`".sub(/\n/,  '') + "\""

    # tipus de dispositiu a muntar (pel comprova_mount)
    @mount_type = s['mount_type']
    @mount_file_to_check = s['mount_file_to_check'].nil? ? "" : s['mount_file_to_check']

    @rsyncd_password = s['rsyncd_password'].nil? ? "" : "RSYNC_PASSWORD='#{s['rsyncd_password']}'"

    @email = s['email']
    @email_body = ""

    # sistema de fitxers del disc on guardarem la copia
    @fs = (fs.nil?)? s['fs'] : fs

    if @fs == "rdiff-backup"
      @backup_prog = "rdiff-backup"
    else
      @backup_prog = "rsync"
    end

    if @fs == 'ext3' or @fs == 'ntfs'
      @opcions += " --delete -a -v"
    elsif @fs == 'fat32'
      # for a rational about the 3601 in fat32
      # see http://www.samba.org/rsync/daylight-savings.html
      @opcions += " --delete --max-delete=100000 -r -t -v --modify-window=3601"
    elsif @fs == 'curlftpfs'
      # mounting ftp with curlftpfs
      @opcions += " --delete -rp -v --size-only"
    elsif @fs == 'rsyncd'
      @opcions += " --delete -a -v"
    elsif @fs == 'rdiff-backup'
      @opcions += " --exclude-sockets"
    else
      escriu_log "[ERROR] Sistema de fitxers no suportat, comprova \"fs\" a #{@Settings}"
    end
    if @fs == "rdiff-backup"
      @opcions += " --exclude-globbing-filelist #{@exclude}"        unless @exclude.nil?
    else
      @opcions += " --backup --backup-dir=#{@backupDir}"           if @bdays > 0
      @opcions += " --exclude-from=#{@exclude} --delete-excluded"  unless @exclude.nil?
      @opcions += " --dry-run"                                     if @dryrun
    end

    # opcions addicionals per a rsync
    @opcions += " #{s['opcions']}" if s['opcions']

    # nagios service name
    @nagios_name = s["nagios_name"]

    if @debug
      puts "Fitxer de logs: #{@log}"
      puts "LogicalExtentsNumber: #{@LogicalExtentsNumber}"
      puts "Origen: #{@origen}"
      puts "Desti: #{@desti}"
      puts "Dies Historic: #{@bdays}"
      puts "Backup dir: #{@backupDir}"
      puts "filesystem: #{@fs}"
      puts "opcions rsync: #{@opcions}"
    end

  end


  # fa el backup
  def fes_backup
    puts "entrant find_or_create_lock_file" if @debug
    return 102 unless find_or_create_lock_file
    return 103 if @opcions.nil?

    # creem un fitxer per que es copii durant la copia
    # aixi sempre es copiara alguna cosa mentre funcioni el backup
    # cada dia afegim un caracter per que canvii el tamany (curlftpfs usa --size-only)
    unless @origen =~ /^rsync:/ || @origen =~ /::\// || @origen =~ /.*@.*:.*/
      `/bin/echo -n "." >> "#{@origen}.last_copy"`
    end

    #TODO: en cas de fer copia contra rsyncd, com esborrem els historics antics?
    #TODO: en cas de rdiff-backup, --remove-older-than
    error = ( ["rsyncd","rdiff-backup"].include? @fs ) ? 0 : esborraAntics
    return error if error != 0
    return fesRsync
  end

  def find_or_create_lock_file
    FileUtils.mkdir "/var/lock/copiador" unless File.exist? "/var/lock/copiador"
    if File.exist? @lockfile
      escriu_log "[ERROR] rsync encara s'esta executant (#{@lockfile} existeix)"
      return false
    else
      FileUtils.touch @lockfile
      return true
    end
  end

  def rm_lock_file
    File.delete @lockfile
  rescue
  end

  # comprova si esta corrent rsync (retorna true/false)
  # esborra els historics mes antics que @bdays
  def esborraAntics
    puts "entrant esborraAntics (hist dir: #{@historic})" if @debug
    comprova_mount unless ["rsyncd","rdiff-backup"].include? @fs
    antics = `find "#{@historic}" -maxdepth 1 -name \"[0-9][0-9]*-[0-9][0-9]*-[0-9][0-9]*\" -mtime +#{@bdays} 2>>#{@log}`
    if antics.length > 0
      escriu_log 'Esborrant historics:'
      escriu_log antics
      antics = antics.split("\n")
      antics.each do |antic|
        rm_ok = executa("rm -rf #{antic}")
        if !rm_ok
          escriu_log '[ERROR] a l\'esborrar antics'
          escriu_log "backup_exit_value = 1"
          return 101
        end
      end
    end
    return 0
  end

  # executa rsync i fa la copia de seguretat
  def fesRsync
    comprova_mount unless ["rsyncd","rdiff-backup"].include? @fs
    escriu_log "#{@rsyncd_password} nice -n 19 #{@backup_prog} #{@opcions} \"#{@origen}\" \"#{@desti}\""
    code = executa("#{@rsyncd_password} nice -n 19 #{@backup_prog} #{@opcions} \"#{@origen}\" \"#{@desti}\"")

    puts code
    #               success = (code != 0 ? "[ERROR] al fer el backup (codi #{@code})" : "BACKUP OK")
    #TODO perque dona error al escriure al log "BACKUP OK" ??? ???
    #escriu_log "BACKUP OK"
    escriu_log "backup_exit_value = #{code}"
    return code
  end

  # executa una comanda i retorna el que ha retornat aquesta ($?)
  def executa(comanda)
    puts "entrant executa" if @debug
    res = `#{comanda} >> #{@log} 2>&1 ; echo $?`
    #escriu_log res
    return res.split.last.to_i
  end

  # escriu un missatge al log
  def escriu_log(missatge)
      if @email
          @email_body += "#{missatge}\r\n"
      end
    #puts "escriu_log: echo #{missatge} >> #{@log}"
    @log = "/var/log/arxiver" unless @log
    a = `echo "[copiador] #{missatge}" >> #{@log}`
  end

  # recupera les dades del fitxer de configuracio
  def recupera_settings
    begin
      YAML::load_file(@Settings)
    rescue => detail
      escriu_log "Configurar a '#{@Settings}'"
      exit
    end
  end

  def envia_nagios(valor)
    @return_code = 2 # critical
    case valor
    when 0
      @return_code = 0 # ok
    when 23, 24, 25
      @return_code = 1 # warning
    end
    puts "envia_nagios: \"/usr/local/bin/nsca_send '#{@nagios_name}\t#{@return_code}\tRSYNC: #{rsync_code(valor)}'\""
    executa("/usr/local/bin/nsca_send '#{@nagios_name}\t#{@return_code}\tRSYNC: #{rsync_code(valor)}'")
  end

  def rsync_code(valor)
    h = {  0  => "Success",
      1 => "Syntax or usage error",
      2 => "Protocol incompatibility",
      3 => "Errors selecting input/output files, dirs",
      4 => "Requested action not supported: an attempt was made to manipulate 64-bit files on a platform that  cannot  support them; or an option was specified that is supported by the client and not by the server.",
      5 => "Error starting client-server protocol",
      6 => "Daemon unable to append to log-file",
      10 => "Error in socket I/O",
      11 => "Error in file I/O",
      12 => "Error in rsync protocol data stream",
      13 => "Errors with program diagnostics",
      21 => "Some error returned by waitpid()",
      22 => "Error allocating core memory buffers",
      23 => "Partial transfer due to error",
      24 => "Partial transfer due to vanished source files",
      25 => "The --max-delete limit stopped deletions",
      30 => "Timeout in data send/receive",
      101 => "Error esborrant historics",
      102 => "Rsync corrent en el moment de fer la seguent copia",
      103 => "Copiador sense configurar"
    }
    "#{valor} #{h[valor]}"
  end

  # comprova que el disc usb estigui ben muntat
  # al comprovar-ho l'autofs intenta montar-lo
  # si no funciona recarreguem el modul
  def comprova_mount()
    10.times do
      if File.exists? @desti + @mount_file_to_check
        escriu_log "trobat #{@desti + @mount_file_to_check} (mount ok)"
        return
      end
      sleep 1
    end
    escriu_log "no trobo #{@desti + @mount_file_to_check}"
    if @mount_type == "usb"
      escriu_log "recarregant el modul usb_storage"
      executa("/sbin/modprobe -r usb_storage ; /sbin/modprobe usb_storage")
      executa("/etc/init.d/autofs restart")
      sleep 10
    end
    10.times do
      if File.exists? @desti + @mount_file_to_check
        escriu_log "trobat #{@desti + @mount_file_to_check} (mount ok)"
        return
      end
      sleep 1
    end
    escriu_log "no s'ha pogut muntar #{@desti}"
    if @mount_type == "usb"
      if File.exist?("/sbin/lsusb")
        escriu_log "#{`/sbin/lsusb`}"
      elsif File.exist?("/usr/bin/lsusb")
        escriu_log "#{`/usr/bin/lsusb`}"
      else
        escriu_log "no trobo lsusb"
      end
    end
  end

  def email_subject(valor)
      case valor
      when 0
          "OK"
      when 23, 24, 25
          "Warning"
      else
          "Critical"
      end
  end

  def envia_mail(r)
      if @email
          from = "suport@ingent.net"
          to = @email
          message = <<MESSAGE
From: Copiador #{@nagios_name} <#{from}>
To: #{to}
MIME-Version: 1.0
Content-type: text/html
Subject: Backup #{email_subject(r)}
MESSAGE

      s=Net::SMTP.start('localhost',25) do |smtp|
          smtp.send_message [message, @email_body].join("\r\n"),from,to
      end
      end
  end
end

if __FILE__ == $0

  def work(cop)
    cop.escriu_log("--------------")
    cop.escriu_log("Inici: #{Time.now}")
    cop.escriu_log("--------------")

    exit_value = cop.fes_backup
    cop.envia_nagios(exit_value)
    cop.rm_lock_file unless exit_value == 102

    cop.escriu_log("--------------")
    cop.escriu_log("Fi: #{Time.now}")
    cop.escriu_log("--------------\n\n\n")

    cop.envia_mail(exit_value)
  end

  if ARGV.length > 0
    ARGV.each do |conf|
      cop = Copiador.new conf
      cop.escriu_log("fent backup segons fitxer: #{conf}")
      work(cop)
      sleep 30 if ARGV.length > 1 # wait 30 seconds between backups
    end
  else
    cop = Copiador.new
    cop.escriu_log("s'ha cridat copiador.rb sense especificar fitxer de configuracio")
    cop.envia_nagios(1)
    cop.envia_mail(1)
  end

end
