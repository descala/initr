class Initr::KlassDefinition

  unloadable

  attr_accessor :name, :description

  def self.all
    self.custom_klasses
  end

  def self.custom_klasses
    kdefs = Initr::KlassName.all.sort.collect { |kn|
      Initr::KlassDefinition.new(kn.name,kn.description)
    }
    kdefs << Initr::KlassDefinition.new("CustomKlass","Custom class")
    kdefs.sort
  end

  def initialize(name,description)
    @name = name
    @description = description
  end

  def self.all_for_node(node)
    self.all
    kdefs = []
    node.klasses.each do |k|
      kdefs << self.find_by_name(k.name)
    end
    kdefs
  end

  def self.find_by_name(name)
    ObjectSpace.each_object(Initr::KlassDefinition) { |kd|
      return kd if kd.name == name
    }
    return find_by_name("CustomKlass")
  end

  def ==(oth)
    self.name == oth.name
  end
  
  def <=>(oth)
    return -1 if self.name == 'base'
    return  1 if oth.name  == 'base'
    self.name.downcase <=> oth.name.downcase
  end

end

