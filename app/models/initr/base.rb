class Initr::Base < Initr::Klass

  unloadable
  require "ostruct"

  ATTRIBUTES = ["puppet"]

  def after_create
    if read_attribute(:config).nil?
      self.config=OpenStruct.new(ATTRIBUTES)
      self.config.puppet=:none
    end
    save
  end

  def name
    "base"
  end

  def description
    "Initr base class"
  end

  def parameters
    conf = self.config.marshal_dump.stringify_keys
    conf.each do |k,v|
      conf.delete(k) if v.nil?
    end
    conf.delete("puppet")
    return conf
  end

  def more_classes
    case self.config.puppet
    when "lite"
      return ["puppet::lite"]
    when "normal"
      return ["puppet"]
    else
      return nil
    end
  end

  def config
    return OpenStruct.new(ATTRIBUTES) if read_attribute(:config).nil?
    return read_attribute(:config)
  end

  def respond_to?(m)
    return true if(ATTRIBUTES.include?(m.to_s) or ATTRIBUTES.include?(m.to_s.gsub(/=$/,'')))
    super(m)
  end

  def print_parameters
    ""
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

  # Don't allow to copy this class
  # see copy_klass module
  def copyable?
    false
  end

  def movable?
    false
  end

  def removable?
    false
  end

  protected

  def method_missing(m, *args)
    if ATTRIBUTES.include?(m.to_s) or ATTRIBUTES.collect {|a| "#{a}="}.include?(m.to_s)
      return config.send(m,*args) 
    else
      super
    end
  end

end
