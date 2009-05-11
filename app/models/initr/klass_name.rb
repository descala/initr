class Initr::KlassName < ActiveRecord::Base

  unloadable
  
  has_many :klasses, :class_name => "Initr::Klass"
  has_many :nodes, :through => :klasses, :class_name => "Initr::Node"
  has_and_belongs_to_many :conf_names, :class_name => "Initr::ConfName"
  has_many :confs, :through => :conf_names, :class_name => "Initr::Conf"

  validates_presence_of :name
  validates_uniqueness_of :name

  def needed_confs
    conf_names
  end

  def validate
    errors.add_to_base("Name must be a valid puppet class name, without strange characters or spaces.") if name =~ /[^A-Za-z0-9_:]/
  end
  
  def <=>(oth)
    return -1 if self.name == 'Base'
    return  1 if oth.name  == 'Base'
    self.name <=> oth.name
  end

end