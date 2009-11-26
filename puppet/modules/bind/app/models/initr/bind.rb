class Initr::Bind < Initr::Klass

  unloadable
  has_many :bind_zones,
    :class_name => "Initr::BindZone",
    :dependent => :destroy

  def name
    "bind"
  end

  def parameters
    bind_masterzones = {}
    self.bind_zones.each do |z|
      bind_masterzones[z.domain]=z.parameters
    end
    { "bind_masterzones" => bind_masterzones }
  end

end
