class Initr::SshStation < Initr::Klass
  has_many :ssh_station_ports, :dependent => :destroy
  self.accessors_for(%w(additional_ssh_config))
  after_create :assign_standard_ports

  def name
    "ssh_station::client"
  end

  def parameters
    raise Initr::Klass::ConfigurationError.new("Missing ssh_station_server") unless ssh_station_server
    initr_ports = []
    ssh_station_ports.sort.each do |port|
      initr_ports << port.parameters
    end
    authorized_keys = []
    self.node.project.users.each do |u|
      #TODO: check for user permisions
      pubkey = self.ssh_station_server.node.fact("initr_#{u.login}_operator_key")
      next if pubkey.nil? or pubkey.size <= 0
      authorized_keys << Initr::PublicKey.to_hash(pubkey)
    end
    raise Initr::Klass::ConfigurationError.new("Empty authorized_keys") unless authorized_keys.size > 0
    return { "initr_ports" => initr_ports,
      "ssh_proxytunnel" => ssh_proxytunnel,
      "ssh_station_server" => ssh_station_server.node.fqdn,
      "ssh_station_server_ip" => (ssh_station_server.ip.blank? ? ssh_station_server.node.fqdn : ssh_station_server.ip),
      "authorized_keys" => authorized_keys,
      "tags_for_sshkey" => "ssh_station_clients_for_#{ssh_station_server.node.fqdn}",
      "additional_ssh_config" => additional_ssh_config }
  end

  def print_parameters
    str="Ports: "
    ssh_station_ports.each do |port|
      str += "#{port.service}, "
    end
    return str.chop.chop
  end

  def ssh_station_server_id
    return nil unless config["server_id"] and config["server_id"].size > 0
    config["server_id"]
  end

  def ssh_station_server_id=(server_id)
    conf = self.config
    conf["server_id"] = server_id
    self.config = conf
    save
  end

  def ssh_station_server
    return nil unless config["server_id"] and config["server_id"].size > 0
    Initr::SshStationServer.find(config["server_id"]) rescue nil
  end

  def ssh_station_server=(sss)
    conf = self.config
    conf["server_id"] = sss.id
    self.config = conf
    save
  end

  def ssh_proxytunnel
    if config.nil?
      return false
    else
      return config["ssh_proxytunnel"] || false
    end
  end

  def ssh_proxytunnel=(spt)
    self.config["ssh_proxytunnel"] = spt
  end
  
  def port_for_service(service)
    ssh_station_ports.where(service: service).first
  end

  # Other klasses can define port redirections with "default_ssh_ports" method
  # it must return a hash with { "host:port" => "name" } like this class does
  def recomended_ports
    rp = { "localhost:22" => "ssh" }
    self.node.klasses.each do |k|
      rp = rp.merge(k.default_ssh_ports) if k.respond_to? "default_ssh_ports"
    end
    self.ssh_station_ports.each do |ap|
      rp.delete(ap.to_s)
    end
    rp
  end
  
  private

  # ssh
  def assign_standard_ports
    ["22"].each do |n|
      port = Initr::SshStationPort.new
      port.name = "ssh" if n == "22"
      port.service = n
      port.ssh_station = self
      port.host = "localhost"
      port.save
    end
  end
end
