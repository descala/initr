class Initr::CopyKlass < Initr::Klass

  unloadable
  validates_presence_of :copied_klass_id, :on => :update
  validates_uniqueness_of :copied_klass_id, :scope => :node_id

  # Allow more than one CopyKlass per node
  # see validates_uniqueness_of on Klass
  def unique?; false end

  def name
    copied_klass.nil? ? "CopyKlass" : copied_klass.name
  end

  def print_parameters
    "Copied klass from #{copied_klass.node.fqdn}"
  end

  def parameters
    if copied_klass.nil?
      raise Initr::Klass::ConfigurationError.new("CopyKlass with empty or bad copied_klass_id")
    end
    copied_klass.parameters
  end

  def copied_klass_id
    config["copied_klass_id"]
  end

  def copied_klass_id=(ckid)
    config["copied_klass_id"]=ckid
  end

  def copied_klass
    Initr::Klass.find copied_klass_id
  rescue ActiveRecord::RecordNotFound => e
    nil
  end

end
