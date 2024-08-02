#!/usr/bin/ruby

# /etc/in/in.conf
#
# services = "ingent_network"
#
# a la configuracio per defecte services = "ingent_network"
# services pot ser "ingent_network", "hosting" (web, email), "" (servidor ingent)

# Script to get a list of services in this server

# old versions of ruby, always "ingent_network"
if RUBY_VERSION < "1.9"
    host = `hostname -f`.chomp
    puts '[{"service":"ingent_network","service_id":"' + host + '","host":"' + host + '"}]'
    exit
end

require 'socket'
require 'json'

@my_ips = Socket.ip_address_list.collect { |a| a.ip_address }
@host = `hostname -f`.chomp
@found_services = []
@outdated_webs = []
@config = {}

# cercar webs i comptes e-mail

def find_webs(path, service)
  return unless File.directory?(path)

  items = Dir.entries(path)
  webs = items.each { |f| f.chomp!('.conf') } # obté llista dels noms de webs

  webs.each do |web|
    web.gsub!(/^http_/,'')
    next unless web =~ /^([a-zA-Z0-9-]{1,61}\.)?[a-zA-Z0-9-]{1,61}\.[a-zA-Z]{2,}$/ # nomes noms tipus abcd0.abcd0.abcd

    ip = `dig a #{web} +short +time=5 +tries=5 2>&1`.split.join(' ') # podria valer la pena modifcar time i tries ?
    ip = 'none' if ip == ''

    # extreu la ip en els casos de cname
    lines = ip.split(" ")
    if lines.length > 1
      ip = lines[1]
    end

    # IP nostre o d'un WAF
    if @my_ips.include?(ip) || `host #{ip}` =~ /sucuri.net/
      @found_services << { 'service' => service, 'service_id' => web, 'host' => @host }
    else
      @outdated_webs << { 'service_id' => web, 'ip' => ip }
    end
  end
end

def find_email(path, service)
  return unless File.directory?(path)

  items = Dir.entries(path)

  items.each do |item|
    next unless item =~ /^([a-zA-Z0-9-]{1,61}\.)?[a-zA-Z0-9-]{1,61}\.[a-zA-Z]{2,}$/ # nomes noms tipus abcd0.abcd0.abcd

    @found_services << { 'service' => service, 'service_id' => item, 'host' => @host }
  end
end

def find_email_in_docker(service)
  # nomes funciona en el ruug

  items = `docker exec mailcowdockerized_dovecot-mailcow_1 ls /var/vmail`.split("\n")

  items.each do |item|
    next unless item =~ /^([a-zA-Z0-9-]{1,61}\.)?[a-zA-Z0-9-]{1,61}\.[a-zA-Z]{2,}$/ # nomes noms tipus abcd0.abcd0.abcd

    @found_services << { 'service' => service, 'service_id' => item, 'host' => @host }
  end
rescue StandardError
  # STDERR.puts "No hi ha docker en aquest servidor"
end

# cercar noms de domini

def find_domain_names

  if @config['entorno-file'] != '' and !@config['entorno-file'].nil?

    file = File.open('/etc/in/' + @config['entorno-file'], 'r')
    data = file.read
    file.close
    data = data.split("\n")

    data.each do |d|
      next unless d.split("\t")[0] != 'Dominio'

      service_id = d.split("\t")[0]
      service = 'service.' + d.split("\t")[0].split('.')[1]
      @found_services << { 'service' => service, 'service_id' => service_id, 'host' => @host }
    end
  end

  if @config['api-key-gandi'] != '' and !@config['api-key-gandi'].nil?

    @config['api-key-gandi'] = "Apikey " + @config['api-key-gandi']
    require 'rest-client'
    begin
      url = 'https://api.gandi.net/v5/domain/domains'
      params = {}
      headers = { :Authorization => @config['api-key-gandi'].to_s }

      response = RestClient.get url, headers
      data = JSON.parse response

      data.each do |d|
        @found_services << { 'service' => 'service.' + d['tld'], 'service_id' => d['fqdn'], 'host' => @host }
      end
    rescue StandardError
      # warn 'Error al accedir API gandi'
    end
  end

  if @config['api-key-arsys'] != '' and !@config['api-key-arsys'].nil?

    require 'rest-client'
    begin
      url = 'https://domain.apitool.info/v2/domains'
      params = {}
      headers = { 'X-TOKEN' => @config['api-key-arsys'].to_s }

      response = RestClient.get url, headers
      data = JSON.parse response

      data.each do |d|
        @found_services << { 'service' => 'service.' + d['domain'].split('.')[1], 'service_id' => d['domain'], 'host' => @host }
      end
    rescue StandardError
      # warn 'Error al accedir API arsys'
    end
  end
end

# servidors hetzner

def find_servers()

  if @config['api-keys-hetzner'] != '' and !@config['api-keys-hetzner'].nil?
    require 'rest-client'
    begin
      api_keys = @config['api-keys-hetzner'].split("%")
      url = 'https://api.hetzner.cloud/v1/servers'

      api_keys.each do |k|
        params = {}
        headers = { 'Authorization' => 'Bearer ' + k.to_s }
        response = RestClient.get url, headers
        data = JSON.parse response

        data["servers"].each do |s|
          @found_services << { 'service' => s['server_type']['name'], 'service_id' => s['name'], 'host' => @host }
        end
      end
    rescue StandardError
      #warn 'Error al accedir API hetzner'
    end
  end
end

# llegir fitxer de configuracio i cridar funcions

if File.exist?('/etc/in/in.conf')

  file = File.open('/etc/in/in.conf', 'r')
  data = file.read
  file.close

  # make json from config lines
  lines = data.split("\n")
  lines.each do |l|
    next unless l[0] != '#'
    begin
      key = l.split('=')[0].tr!(' ', '').tr('"', '')
      value = l.split('=')[1].tr!(' ', '').tr('"', '')
      @config[key] = value
    rescue
    end
  end
end

# servidors
find_servers()

# dominis
find_domain_names()

# hosting
if @config['services'] == 'hosting'
  find_webs('/etc/apache2/sites-enabled', 'apache.hosting.standard')
  find_webs('/etc/nginx/sites-enabled', 'nginx.hosting.standard')
  find_email('/var/vmail', 'mail.versio1')
  find_email_in_docker('mail.versio2')
end

# ingent network
@found_services << { 'service' => 'ingent_network', 'service_id' => @host, 'host' => @host } if @config['services'] == 'ingent_network'

# ingent
@found_services << {} if @found_services.empty?

# output
puts @found_services.to_json

# @outdated_webs << {} if @outdated_webs.empty?
# warn @outdated_webs.to_json
