class Initr::MuninServer < Initr::Klass


  self.accessors_for ["authorized_referer","protocol","url","cgi"]

  after_initialize {
    authorized_referer ||= Setting.host_name
    protocol           ||= "http"
    if self.node
      url ||= self.node.fqdn
    end
  }

  def name
    "munin::server"
  end

  def parameters
    conf = []

    self.nodes.sort.each do |n|

      # Only node instances
      next unless n.type == "Initr::NodeInstance"

      # Include only nodes with the Munin klass
      next unless n.klasses.where(type: 'Initr::Munin').first

      # a non-valid fqdn makes munin to fail parsing configuration file
      next unless n.valid_fqdn?

      # active projects only
      next unless n.project.active?

      # Look for an Initr::SshStation klass
      ssh_station = n.klasses.where(type: 'Initr::SshStation').first

      if ssh_station
        # It uses ssh_station
        # look for a munin port in thar klass
        port = ssh_station.port_for_service 4949
        next unless port
        port_number = port.num
      else
        # It does not use ssh_station
        port_number = 4949
      end

      conf << [n.fqdn,port_number]

    end
    { 'munin_nodes' => conf,
      'authorized_referer' => authorized_referer,
      'munin_server_url' => url,
      'munin_cgi' => cgi,
      'packages_from_squeeze' => ["munin"] # http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=585027
    }
  end

  def controller
    "munin_server"
  end

  def description
    "Class to configure a munin server"
  end

  def nodes
    Initr::Munin.all.order('name').collect {|m| m.node if m.server and m.server.id == id }.compact
  end

  def to_s
    self.node.fqdn
  end

end
