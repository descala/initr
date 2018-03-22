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
        pubkey = u.custom_value_for(UserCustomField.find_by_name("public key")).value rescue next
        next if pubkey.nil? or pubkey.size <= 0
        if operators[u.login]
          operators[u.login]['nodes'] << n.fqdn
        else
          operators[u.login] = {'pubkey'=>Initr::PublicKey.to_hash(pubkey),'nodes'=>[n.fqdn]}
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
      sss.node if active? and sss.ssh_station_server_id == id.to_s and sss.node and sss.node.project.active?
    }.compact
  end

  def ssh_info
    ssh_info = []
    self.nodes.sort.each do |n|
      next unless n.is_a? Initr::NodeInstance # Skip node templates
      node_key = n.fact("ssh_station_sshdsakey")
      node_port = n.klasses.find_by_type("Initr::SshStation").port_for_service(22).num rescue nil
      next if node_key.nil? or node_port.nil?
      ssh_info << [n.fqdn,node_port,node_key]
    end
    ssh_info
  end

  def ssh_config_ng
    ssh_info = []
    self.nodes.sort.each do |n|
      next unless n.is_a? Initr::NodeInstance # Skip node templates
      node_key = n.fact("ssh_station_sshdsakey")
      node_port = n.klasses.find_by_type("Initr::SshStation").port_for_service(22).num rescue nil
      next if node_key.nil? or node_port.nil?
      ssh_info << %{Host #{n.fqdn}
  ProxyCommand ssh -W localhost:#{node_port} root@#{self.node.fqdn}
}
    end
    ssh_info
  end
end
