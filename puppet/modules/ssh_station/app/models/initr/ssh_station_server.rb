class Initr::SshStationServer < Initr::Klass

  self.accessors_for(["ip"])

  def name
    "ssh_station::server"
  end

  def configurable?
    false
  end

  def parameters
    operators = {}
    # operators["login"] = { 'pubkey' => {}, nodes => {} }
    self.nodes.each do |n|
      next unless n.is_a? Initr::NodeInstance # Skip node templates
      n.project.users.each do |u|
        #TODO: check for user permisions
        pubkeys = u.custom_value_for(UserCustomField.find_by_name("public key")).value rescue nil
        next if pubkeys.blank?
        if operators[u.login]
          operators[u.login]['nodes'] << n.fqdn
        else
          operators[u.login] = {
            'pubkeys' => pubkeys.lines.reject {|k| k.blank? }.collect {|k| Initr::PublicKey.to_hash(k) },
            'nodes' => [n.fqdn]
          }
        end
      end
    end
    { 'ssh_info'=>self.ssh_info, 'operators'=>operators, 'tags_for_sshkey'=>"#{self.node.fqdn}_sshst_server", 'host_alias_for_sshkey' => ip }
  end

  def description
    "Ssh station server"
  end

  def to_s
    self.node.fqdn
  end

  def nodes
    Initr::SshStation.all.order('name').collect { |sss|
      sss.node if active? and sss.ssh_station_server_id.to_i == id.to_i and sss.node and sss.node.project.active?
    }.compact
  end

  def ssh_info
    ssh_info = []
    self.nodes.sort.each do |n|
      next unless n.is_a? Initr::NodeInstance # Skip node templates
      node_key = n.fact("ssh_station_sshrsakey")
      node_key = n.fact("ssh_station_sshdsakey") if node_key.blank?
      ssh_klass = n.klasses.find_by_type("Initr::SshStation")
      node_port = ssh_klass.port_for_service(22).num rescue nil
      # TODO include ssh port in ssh_info, because may not be 22
      node_port ||= ssh_klass.ssh_station_ports.where(name: 'ssh').first.num rescue nil
      next if node_key.nil? or node_port.nil?
      ssh_info << [n.fqdn,node_port,node_key]
    end
    ssh_info
  end

  def ssh_config_ng
    ssh_info = []
    self.nodes.sort.each do |n|
      next unless n.is_a? Initr::NodeInstance # Skip node templates
      node_key = n.fact("ssh_station_sshrsakey")
      node_port = n.klasses.find_by_type("Initr::SshStation").port_for_service(22).num rescue nil
      next if node_key.nil? or node_port.nil?
      ssh_info << %{Host #{n.fqdn}
  ProxyCommand ssh -W localhost:#{node_port} root@#{self.node.fqdn}
}
    end
    ssh_info
  end
end
