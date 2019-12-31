class Initr::CustomKlass < Initr::Klass
  has_many :custom_klass_confs,
    :class_name => "Initr::CustomKlassConf",
    :dependent => :destroy
  accepts_nested_attributes_for :custom_klass_confs,
    :allow_destroy => true,
    :reject_if => proc {|attributes| attributes['name'].blank? or attributes['value'].blank?}

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :node_id

  # Allow more than one CutomKlass per node
  # see validates_uniqueness_of on Klass
  def unique?; false end

  def name
    read_attribute :name
  end

  def pretty_name
    name.split("::").join(":: ")
  end

  def description
    read_attribute :description
  end

  def parameters
    parameters = {}
    custom_klass_confs.sort.each do |ckc|
      parameters[ckc.name] = ckc.value
    end
    parameters
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
end

