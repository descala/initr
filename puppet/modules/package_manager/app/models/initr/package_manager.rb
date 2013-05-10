class Initr::PackageManager < Initr::Klass
  unloadable

  self.accessors_for(["security_updates"])

  def initialize(attributes=nil)
    super
    config["packages_from_squeeze"] ||= ["puppet","rubygems","rubygems1.8"]
    config["packages_from_wheezy"]  ||= []
    config["packages_from_jessie"]  ||= []
    config["security_updates"] ||= "0"
  end

  def parameters
    { "packages_from_squeeze" => config["packages_from_squeeze"],
      "packages_from_wheezy" => config["packages_from_wheezy"],
      "packages_from_jessie" => config["packages_from_jessie"]
    }
  end

  def class_parameters
    { "security_updates" => security_updates }
  end

  def packages_from_squeeze=(packages)
    config["packages_from_squeeze"] = packages.is_a?(String) ? packages.gsub(/ */,'').split(',') : packages
  end

  def packages_from_squeeze
    config["packages_from_squeeze"].join(', ') rescue ""
  end

  def packages_from_wheezy=(packages)
    config["packages_from_wheezy"] = packages.is_a?(String) ? packages.gsub(/ */,'').split(',') : packages
  end

  def packages_from_wheezy
    config["packages_from_wheezy"].join(', ') rescue ""
  end

  def packages_from_jessie=(packages)
    config["packages_from_jessie"] = packages.is_a?(String) ? packages.gsub(/ */,'').split(',') : packages
  end

  def packages_from_jessie
    config["packages_from_jessie"].join(', ') rescue ""
  end

end
