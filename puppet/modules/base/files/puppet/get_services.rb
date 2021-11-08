#!/usr/bin/ruby

# /etc/in/in.conf
#
# {"api-key-gandi": "",
# "api-key-arsys": "",
# "entorno_file": "lista_dominios.csv",
# "ingent_network": "false"
# }
#

# Script to get a list of services in this server

require 'socket'
require 'json'

@found_services = []
@outdated_webs = []
@my_ips = Socket.ip_address_list.collect { |a| a.ip_address }
@host = `hostname -f`.chomp

if File.exist?('/etc/in/in.conf')

  file = File.open('/etc/in/in.conf', 'r')
  config = file.read
  file.close
  config = JSON.parse(config)

  # ingent_network

  @found_services << { 'service' => 'ingent_network', 'host' => @host } if config['ingent_network'] == 'true'

  # llista noms de domini

  if config['entorno_file'] != '' and config['entorno_file'] != nil

    file = File.open("/etc/in/" + config['entorno_file'], 'r')
    data = file.read
    file.close
    data = data.split("\n")

    data.each do |d|
      next unless d.split("\t")[0] != 'Dominio'

      service_id = d.split("\t")[0].split('.')[0]
      service = 'service.' + d.split("\t")[0].split('.')[1]
      @found_services << { 'service' => service, 'service_id' => service_id }
    end
  end

  if config['api-key-gandi'] != '' and config['api-key-gandi'] != nil

    require 'rest-client'
    begin
      url = 'https://api.gandi.net/v5/domain/domains'
      params = {}
      headers = { Authorization: config['api-key-gandi'].to_s }

      response = RestClient.get url, headers
      data = JSON.parse response

      data.each do |d|
        @found_services << { 'service' => 'service.' + d['tld'], 'service_id' => d['fqdn'] }
      end
    rescue StandardError
      # warn 'Error al accedir API gandi'
    end
  end

  if config['api-key-arsys'] != '' and config['api-key-arsys'] != nil

    require 'rest-client'
    begin
      url = 'https://domain.apitool.info/v2/domains'
      params = {}
      headers = { 'X-TOKEN' => config['api-key-arsys'].to_s }

      response = RestClient.get url, headers
      data = JSON.parse response

      data.each do |d|
        @found_services << { 'service' => 'service.' + d['domain'].split('.')[1], 'service_id' => d['domain'] }
      end
    rescue StandardError
      # warn 'Error al accedir API arsys'
    end
  end

end

# llista webs i comptes e-mail

def find_webs(path, service)
  return unless File.directory?(path)

  items = Dir.entries(path)
  webs = items.each { |f| f.chomp!('.conf') } # obté llista dels noms de webs

  webs.each do |web|
    next unless web =~ /^([a-zA-Z0-9-]{1,61}\.)?[a-zA-Z0-9-]{1,61}\.[a-zA-Z]{2,}$/ # nomes noms tipus abcd0.abcd0.abcd

    ip = `dig a #{web} +short +time=5 +tries=5 2&>1`.split.join(' ') # podria valer la pena modifcar time i tries ?
    ip = 'none' if ip == ''

    if @my_ips.include?(ip)
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
  # STDERR.puts "no docker in this machine"
end

find_webs('/etc/apache2/sites-enabled', 'apache.hosting.standard')
find_webs('/etc/nginx/sites-enabled', 'nginx.hosting.standard')
find_email('/var/vmail', 'mail.versio1')
find_email_in_docker('mail.versio2')

warn @outdated_webs.to_json
puts @found_services.to_json
