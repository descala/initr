class Initr::CustomKlass < Initr::Klass

  unloadable
  
  belongs_to :klass_name, :class_name => "Initr::KlassName"
  has_many :confs, :dependent => :destroy, :class_name => "Initr::Conf"
  has_many :conf_names, :through => :confs, :class_name => "Initr::ConfName"

  def name
    klass_name.name
  rescue
    "rescued"
  end

  def description
    klass_name.description
  rescue
    "rescued"
  end

  def parameters
    parameters = {}
    confs.sort.each do |conf|
      parameters[conf.name]=YAML.load conf.value_yaml
    end
    parameters
  end

  def configurable?
    return false unless klass_name
    return !klass_name.conf_names.empty?
  end

  def print_parameters
    p = {}
    confs.each do |conf|
      p[conf.name] = conf.get_value
    end
    return "-" if p.empty?
    str = ""
    p.each { |k,v|
      str += "#{k} = #{v}<br />"
    }
    str
  end

end

