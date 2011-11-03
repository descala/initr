class Initr::PackageManager < Initr::Klass
  unloadable

  self.accessors_for(["security_updates"])

  def initialize(attributes=nil)
    super
    config["packages_from_squeeze"] ||= ["puppet","rubygems","rubygems1.8"]
    config["packages_from_wheezy"]  ||= []
    config["security_updates"] ||= "0"
  end

  def parameters
    { "packages_from_squeeze" => config["packages_from_squeeze"], "packages_from_wheezy" => config["packages_from_wheezy"] }
  end

  def class_parameters
    { "security_updates" => security_updates }
  end

  def packages_from_squeeze=(packages)
    config["packages_from_squeeze"] = packages.is_a?(String) ? packages.gsub(/ */,'').split(',') : packages
  end

  def packages_from_squeeze
    config["packages_from_squeeze"].join(', ')
  end

  def packages_from_wheezy=(packages)
    config["packages_from_wheezy"] = packages.is_a?(String) ? packages.gsub(/ */,'').split(',') : packages
  end

  def packages_from_wheezy
    config["packages_from_wheezy"].join(', ')
  end

end
