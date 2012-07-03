class Initr::Bind < Initr::Klass

  unloadable
  has_many :bind_zones,
    :class_name => "Initr::BindZone",
    :dependent => :destroy
  validates_presence_of :nameservers, :on => :update

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
    { "nameservers"=>nameservers.split, "bind_masterzones"=>bind_masterzones }
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

end
