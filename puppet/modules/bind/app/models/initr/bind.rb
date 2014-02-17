class Initr::Bind < Initr::Klass

  unloadable
  has_many :bind_zones,
    :class_name => "Initr::BindZone",
    :dependent => :destroy
  validates_presence_of :nameservers,
    :on => :update,
    :if => Proc.new {|bind| bind.bind_zones.any? }

  has_and_belongs_to_many :slaves,
    class_name:              'Bind',
    foreign_key:             'master_id',
    join_table:              'bind_masters_slaves',
    association_foreign_key: 'slave_id'

  has_and_belongs_to_many :masters,
    class_name:              'Bind',
    foreign_key:             'slave_id',
    join_table:              'bind_masters_slaves',
    association_foreign_key: 'master_id'

  delegate :fqdn, :to => :node, :prefix => true # allows to use @bind.node_fqdn

  self.accessors_for(%w(ipaddress))

  def name
    "bind"
  end

  def parameters
    {}
  end

  def class_parameters
    return { "nameservers"=>[], "bind_masterzones"=>{}} if bind_zones.size == 0
    if nameservers.nil? or nameservers.blank?
      raise Initr::Klass::ConfigurationError.new("Bind nameservers not configured")
    end
    bind_masterzones = {}
    self.bind_zones.each do |z|
      bind_masterzones[z.domain]=z.parameters
    end
    {
      "nameservers"        => nameservers.split,
      "bind_masterzones"   => bind_masterzones,
      "bind_slave_zones"   => slave_zones,
      "bind_slave_servers" => slave_servers
    }
  end

  def nameservers
    config["nameservers"]
  end

  def nameservers=(ns)
    config["nameservers"]=ns
  end

  def print_parameters
    "#{bind_zones.size} zones configured"
  end

  def clone
    copy = Initr::Bind.new(self.attributes)
    self.bind_zones.each do |bz|
      bz_copy = bz.clone
      bz_copy.bind_id = nil
      copy.bind_zones << bz_copy
    end
    copy
  end

  private

  def slave_zones
    sz = {}
    masters.each do |master|
      next unless master.bind_zones.any?
      if master.ipaddress.blank?
        raise Initr::Klass::ConfigurationError.new("bind: missing IP address on master")
      else
        sz[master.ipaddress] = master.bind_zones.collect {|z| z.domain }
      end
    end
    sz
  end

  def slave_servers
    ss = []
    slaves.each do |slave|
      if slave.ipaddress.blank?
        raise Initr::Klass::ConfigurationError.new("bind: missing IP address on slave")
      else
        ss << slave.ipaddress
      end
    end
    ss
  end

end
