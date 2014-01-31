class Initr::Base < Initr::Klass

  unloadable

  self.accessors_for(%w(puppet))

  def initialize(attributes=nil)
    super
    self.puppet ||= "none"
  end

  def name
    "base"
  end

  def description
    "Initr base class"
  end

  def parameters
    begin
      conf = self.config.dup
      conf.delete("puppet") # see more_classes
      conf["initr_url"]="#{Setting[:protocol]}://#{Setting[:host_name]}"
    rescue
      conf = {}
    end
    return conf
  end

  def more_classes
    case self.puppet
    when "lite"
      return ["base::puppet::lite"]
    when "normal"
      return ["base::puppet"]
    when "insistent"
      return ["base::puppet::insistent"]
    when "lite_insistent"
      return ["base::puppet::lite_insistent"]
    else
      return []
    end
  end

  def print_parameters
    ""
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
    return true if self.node.is_a? Initr::NodeTemplate
    false
  end

end
