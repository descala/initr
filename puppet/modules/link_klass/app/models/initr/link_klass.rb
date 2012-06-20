class Initr::LinkKlass < Initr::Klass

  unloadable
  validates_presence_of :copied_klass_id
  validate :copied_klass_unique_for_node

  def copied_klass_unique_for_node
    if node
      node.klasses.all(:conditions=>["type='LinkKlass'"]).each do |ck|
        errors.add_to_base("Klass already copied on this node") if ck.copied_klass_id == copied_klass_id
      end
    end
  end

  # Allow more than one LinkKlass per node
  # see validates_uniqueness_of on Klass
  def unique?; false end

  def name
    copied_klass.nil? ? "LinkKlass" : copied_klass.name
  end

  def print_parameters
    if copied_klass
      "Copied klass from #{copied_klass.node.fqdn}"
    else
      "Klass to link not selected"
    end
  end

  def parameters
    if copied_klass.nil?
      raise Initr::Klass::ConfigurationError.new("LinkKlass with empty or bad copied_klass_id")
    end
    copied_klass.parameters
  end

  def class_parameters
    if copied_klass.nil?
      raise Initr::Klass::ConfigurationError.new("LinkKlass with empty or bad copied_klass_id")
    end
    copied_klass.class_parameters
  end

  def copied_klass_id
    self.config ||= {}
    self.config["copied_klass_id"]
  end

  def copied_klass_id=(ckid)
    self.config ||= {}
    self.config["copied_klass_id"]=ckid
  end

  def copied_klass
    Initr::Klass.find copied_klass_id
  rescue ActiveRecord::RecordNotFound => e
    nil
  end

  def copyable?
    false
  end

end
