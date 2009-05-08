class Initr::Klass < ActiveRecord::Base

  unloadable
  
  belongs_to :node, :class_name => "Initr::Node"
  belongs_to :klass_name, :class_name => "Initr::KlassName"
  has_many :confs, :dependent => :destroy, :class_name => "Initr::Conf"
  has_many :conf_names, :through => :confs, :class_name => "Initr::ConfName"

  serialize :config

  def name
    klass_name.name
  end

  def name4puppet
    name
  end

  def description
    klass_name.description
  end

  def controller
    self.class.to_s.gsub(/^Initr::/,'').underscore
  end
  
  # Other klasses may need to override this
  def parameters
    parameters = {}
    confs.sort.each do |conf|
      parameters[conf.name]=YAML.load conf.value_yaml
    end
    parameters
  end
  
  def configurable?
    if self.class == Initr::Klass
      return false unless klass_name
      return !klass_name.conf_names.empty?
    else
      return true
    end
  end
  
  # Other klasses may need to override this
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

  def <=>(oth)
    self.klass_name <=> oth.klass_name
  end

end
