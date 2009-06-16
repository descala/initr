class Initr::KlassDefinition

  unloadable

  attr_accessor :name, :description

  def self.all
    Initr::Plugin.klass_names
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
      return kd if kd.name.downcase == name.downcase
    }
    return nil
  end

  def ==(oth)
    self.name.downcase == oth.name.downcase
  end
  
  def <=>(oth)
    return -1 if self.name == 'base'
    return  1 if oth.name  == 'base'
    self.name.downcase <=> oth.name.downcase
  end

end

