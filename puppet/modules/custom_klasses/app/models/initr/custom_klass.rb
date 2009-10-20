class Initr::CustomKlass < Initr::Klass

  unloadable
  has_many :custom_klass_confs,
    :class_name => "Initr::CustomKlassConf",
    :dependent => :destroy
  after_update :save_custom_klass_confs
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :node_id
  validates_associated :custom_klass_confs

  def initialize(attributes=nil)
    super
  end
  
  # Allow more than one CutomKlass per node
  # see validates_uniqueness_of on Klass
  def unique?; false end
  
  def name
    read_attribute :name
  end

  def description
    read_attribute :description
  end

  def parameters
    parameters = {}
    custom_klass_confs.sort.each do |ckc|
      parameters[ckc.name] = YAML.load ckc.value.gsub(/\n/,"\n\n")
    end
    parameters
  end

  def configurable?
    true
  end

  def print_parameters
    p = custom_klass_confs
    return "-" if p.empty?
    str = ""
    p.each { |ckc|
      str += "#{ckc.name} = #{ckc.value}<br />"
    }
    str
  end

  def new_custom_klass_conf_attributes=(ckc_attributes)
    ckc_attributes.each do |attributes|
      custom_klass_confs.build(attributes)
    end
  end

  def existing_custom_klass_conf_attributes=(ckc_attributes)
    custom_klass_confs.reject(&:new_record?).each do |ckc|
      attributes = ckc_attributes[ckc.id.to_s]
      if attributes
        ckc.attributes = attributes
        ckc.save
      else
        custom_klass_confs.delete(ckc)
      end
    end
  end

  def save_custom_klass_confs
    custom_klass_confs.each do |ckc|
      ckc.save(false)
    end
  end

end

