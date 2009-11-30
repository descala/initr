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

end
