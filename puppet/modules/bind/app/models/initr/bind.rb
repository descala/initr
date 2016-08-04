class Initr::Bind < Initr::Klass

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

  self.accessors_for(%w(nameservers ipaddress allowed_ips))

  def name
    "bind"
  end

  def parameters
    {}
  end

  def class_parameters
    unless bind_zones.size == 0
      if nameservers.nil? or nameservers.blank?
        raise Initr::Klass::ConfigurationError.new("Bind nameservers not configured")
      end
    end
    bind_masterzones = {}
    self.bind_zones.each do |z|
      next if z.zone.nil? or z.zone.empty?
      bind_masterzones[z.domain]=z.parameters
    end
    {
      "nameservers"        => (nameservers.split rescue []),
      "bind_masterzones"   => bind_masterzones,
      "bind_slave_zones"   => slave_zones,
      "bind_slave_servers" => slave_servers
    }
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

  def update_active_ns
    bind_zones.each do |z|
      z.update_active_ns
      z.save
    end
  end

  def query_registry
    bind_zones.each do |z|
      next if z.expires_on and z.expires_on > (Date.today + 30)
      z.query_registry
      z.save
    end
  end

  def link_to_invoices
    num = 0
    bind_zones.each do |z|
      z.link_to_invoice
      num = num + 1 if z.changed?
      z.save
    end
    return num
  end

  def nicline_client
    @nicline_client ||= Savon.client(wsdl: "https://webservice.nicline.com/WebServices/ws_apinl.php?wsdl", log: false)
  end

  private

  def slave_zones
    sz = {}
    masters.each do |master|
      next unless master.bind_zones.any?
      if master.ipaddress.blank?
        raise Initr::Klass::ConfigurationError.new("bind: missing IP address on master")
      else
        sz[master.ipaddress] = master.bind_zones.collect do |z|
          z.domain if z.zone and !z.zone.empty?
        end.compact
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
    # add extra allowed ips to slave_servers
    if allowed_ips
      allowed_ips.split(";").each do |ip|
        ss << ip
      end
    end
    ss
  end

end
