class Initr::Munin < Initr::Klass
  @@munin_checks = ["manual", "apache","system","squid","postfix","sendmail","mysql","network","gateway"]
  @@plugins = { "system"   => ["cpu","df","df_abs","hddtemp_smartctl","iostat","load","memory","processes","swap","netstat"],
                "apache"   => ["apache_accesses","apache_processes","apache_volume"],
                "squid"    => ["squid_cache","squid_requests","squid_traffic"],
                "postfix"  => ["postfix_mailqueue","postfix_mailvolume"],
                "sendmail" => ["sendmail_mailqueue","sendmail_mailstats","sendmail_mailtraffic"],
                "mysql"    => ["mysql_bytes","mysql_queries","mysql_slowqueries","mysql_threads"],
                "network"  => [], # if_eth*, if_err_eth*
                "gateway"  => ["fw_conntrack","fw_forwarded_local","fw_packets"] }

  after_initialize {
    conf = self.config
    unless conf["munin_manual"]
      conf["munin_manual"]="1"
      self.config=conf
    end
  }

  def config
    c = super
    return {} unless c.class == Hash
    c
  end

  def server_id
    return nil unless config["server_id"] and config["server_id"].size > 0
    config["server_id"]
  end

  def server_id=(server_id)
    conf = self.config
    conf["server_id"] = server_id
    self.config = conf
    save
  end

  def server
    return nil unless config["server_id"] and config["server_id"].size > 0
    Initr::MuninServer.find(config["server_id"]) rescue nil
  end

  def server=(server)
    conf = self.config
    conf["server_id"] = server.id
    self.config = conf
    save
  end

  def parameters
    # a non-valid fqdn makes munin to fail parsing configuration file
    if !self.node.is_a?(Initr::NodeTemplate) and !self.node.valid_fqdn?
      raise Initr::Klass::ConfigurationError.new("Node has non-valid fqdn")
    end
    mc = []
    if config.nil? or config["munin_manual"].nil? or config["munin_manual"] == "1"
      mc = ["munin_manual"]
    else
      @@munin_checks.each do |name|
        mc << @@plugins[name] if config["munin_#{name}"] == "1"
      end
      if config["munin_network"] == "1"
        self.node.fact("interfaces","").split(",").each do |iface|
          next unless iface =~ /^eth[0-9]$/
          mc << "if_#{iface}"
          mc << "if_err_#{iface}"
        end
      end
    end
    { "munin_checks" => mc.uniq.flatten }
  end

  def print_parameters
    return "-" if server.nil?
    "munin server: #{server}"
  end

  def graph_uri(plugin)
    # Munin server replaces "." with "_" in image names
    "#{server.url}#{"/munin-cgi/munin-cgi-graph" if server.cgi == "1"}/#{node.domain.downcase}/#{node.fqdn.downcase}/#{plugin.gsub(".","_")}.png"
  end
  
  def graph_url(plugin)
    "#{server.protocol}://#{graph_uri(plugin)}"
  end
  
  def graph_url_http(plugin)
    "http://#{graph_uri(plugin)}"
  end

  def default_ssh_ports
    { "localhost:4949" => "munin" }
  end

  def nodelist_partial
    "munin/nodelist"
  end

  # Defines getter and setter for each munin_check
  @@munin_checks.each do |name|
    src = <<-END_SRC
    def munin_#{name}
      config["munin_#{name}"]
    end

    def munin_#{name}=(value)
      config["munin_#{name}"] = value
    end
    END_SRC
    class_eval src, __FILE__, __LINE__
  end
end
