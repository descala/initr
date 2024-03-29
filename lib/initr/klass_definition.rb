class Initr::KlassDefinition


  attr_accessor :name, :description

  def self.all
    Initr::Plugin.klass_names
  end

  def initialize(name,description,unique=true)
    @name = name
    @description = description
    @unique = unique
  end

  def self.all_for_node(node)
    self.all
    kdefs = []
    begin
      node.klasses.each do |k|
        kdefs << self.find_by_name(k.class.to_s.split('::').last.underscore)
      end
    rescue ActiveRecord::SubclassNotFound
    end
    kdefs.compact
  end

  def self.find_by_name(name)
    ObjectSpace.each_object(Initr::KlassDefinition) { |kd|
      return kd if kd.name.to_s.downcase == name.to_s.downcase
    }
    return nil
  end

  # false if a klass can be assigned several times to the same node.
  def unique?
    @unique
  end

  def ==(oth)
    self.name.to_s.downcase == oth.name.to_s.downcase
  end
  
  def <=>(oth)
    return -1 if self.name == 'base'
    return  1 if oth.name  == 'base'
    self.name.to_s.downcase <=> oth.name.to_s.downcase
  end

  def pretty_name
    name.camelize
  end

end

