class Initr::Bind < Initr::Klass

  unloadable
  has_many :bind_zones,
    :class_name => "Initr::BindZone",
    :dependent => :destroy
  validates_presence_of :nameservers, :on => :update
  validates_format_of :ip, :with => /^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$/, :allow_nil => true, :allow_blank => true
  has_and_belongs_to_many :masters, :class_name => "Initr::Bind", :join_table => "bind_masters_slaves", :foreign_key => "slave_id", :association_foreign_key => "master_id"
  has_and_belongs_to_many :slaves,  :class_name => "Initr::Bind", :join_table => "bind_masters_slaves", :foreign_key => "master_id", :association_foreign_key => "slave_id"

  self.accessors_for(%w(nameservers ip))

  def name
    "bind"
  end

  def parameters
    {}
  end

  def class_parameters
    return { "nameservers"=>[], "bind_masterzones"=>{}, "bind_slavezones"=>{}} if bind_zones.size == 0
    if nameservers.nil? or nameservers.blank?
      raise Initr::Klass::ConfigurationError.new("Bind nameservers not configured")
    end
    bind_masterzones = {}
    bind_slavezones  = {}
    self.bind_zones.each do |z|
      if z.master
        bind_masterzones[z.domain]=z.parameters
      else
        bind_slavezones[z.domain]=z.parameters
      end
    end
    self.masters.each do |master_server|
      master_server.master_zones.each do |z|
        unless bind_slavezones[z.domain] or bind_masterzones[z.domain] # don't override self domain configuration
          bind_slavezones[z.domain] = z.parameters_for_slave
        end
      end
    end
    { "nameservers"=>nameservers.split, "bind_masterzones"=>bind_masterzones, "bind_slavezones"=>bind_slavezones }
  end

  def print_parameters
    "#{bind_zones.size} zones configured"
  end

  def master_zones
    bind_zones.find_all_by_master(true)
  end

  def slave_zones
    bind_zones.find_all_by_master(false)
  end

end
