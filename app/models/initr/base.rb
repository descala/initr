class Initr::Base < Initr::Klass

  unloadable
  has_one  :base_conf, :dependent => :destroy, :class_name => "Initr::BaseConf"

  def parameters
    self.base_conf.puppetconf
  end

  def print_parameters
    ""
  end

  def name4puppet
    "base"
  end

  def after_create
    self.base_conf = Initr::BaseConf.new if self.base_conf.nil?
    self.klass_name = Initr::KlassName.find_by_name "Base" if self.klass_name.nil?
    save
  end

  def new_base_conf_attributes=(ic_attributes)
    base_conf.build(ic_attributes.first)
  end

  def existing_base_conf_attributes=(ic_attributes)
    ic_id = base_conf.id.to_s
    attributes = ic_attributes[ic_id]
    if attributes
      base_conf.attributes = attributes
      base_conf.save
    else
      base_conf.delete(base_conf.reject(&:new_record?).first)
    end
  end

end
