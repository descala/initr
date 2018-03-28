class Initr::Smart < Initr::Klass

  attr_accessible :drives

  after_initialize {
    self.drives ||= [[],[]]
  }

  def name
    "smart"
  end

  def print_parameters
    "drives: #{drives.to_json}"
  end

  def drives
    config["drives"]
  end

  def drives=(drives)
    config["drives"]=drives
  end

end
