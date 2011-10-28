class Initr::BindZone < ActiveRecord::Base
  unloadable
  belongs_to :bind, :class_name => "Initr::Bind"
  validates_presence_of :domain, :ttl
  validates_uniqueness_of :domain, :scope => 'bind_id'
  validates_numericality_of :ttl
  validates_format_of :domain, :with => /^[\w\d]+([\-\.]{1}[\w\d]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/i
  validates_format_of :domain, :with => /^[^_]+$/i
  serialize :config

  def initialize(attributes=nil)
    super
    self.ttl ||= "300"
  end

  def parameters
    if master
      {"zone"=>zone,"ttl"=>ttl,"serial"=>serial,"slaves"=>slaves}
    else
      {"masters"=>config}
    end
  end

  def parameters_for_slave
    { "masters" => { self.bind.node.name => {"ip" => self.bind.ip } } }
  end

  def save
    if valid?
      # auto-update serial date (YYYYMMDD) + id 01
      if domain_changed? or ttl_changed? or zone_changed?
        self.serial="#{Time.now.strftime('%Y%m%d')}01".to_i
        unless serial_was.nil?
          while serial <= serial_was.to_i
            self.serial += 1
          end
        end
      end
    end
    super
  end

  def <=>(oth)
    self.domain <=> oth.domain
  end

  def config
    return {} if read_attribute(:config).nil?
    return read_attribute(:config)
  end

  def slave_of=(bind_master_servers)
    masters = {}
    bind_master_servers.each do |name,ip|
      next if name == "custom"
      n=Initr::Node.find_by_name(name)
      next unless n
      b=n.klasses.find_by_type("Bind")
      next unless b and b.ip == bind.ip and ( User.current.projects.include?(b.node.project) or User.current.admin? )
      masters[name] = {"ip" => ip}
    end
    masters["custom"] = { "ip" => bind_master_servers["custom"] } unless bind_master_servers["custom"].blank?
    self.config = masters
  end

  def slaves
    slave_ips = []
    Initr::BindZone.find(:all, :conditions => ["domain = ? and master = ? and id != ?", domain, false, id]).each do |sd|
      next if sd.bind.ip.blank?
      next unless sd.config[self.bind.node.name]
      slave_ips << sd.config[self.bind.node.name]["ip"]
    end
    slave_ips
  end

end
