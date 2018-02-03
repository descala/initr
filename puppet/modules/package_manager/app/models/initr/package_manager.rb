class Initr::PackageManager < Initr::Klass

  attr_accessible :security_updates, :packages_from_squeeze,
    :packages_from_wheezy, :packages_from_jessie, :packages_from_stretch,
    :packages_from_buster

  self.accessors_for(["security_updates"])

  after_initialize {
    config["packages_from_squeeze"] ||= ["puppet","rubygems","rubygems1.8"]
    config["packages_from_wheezy"]  ||= []
    config["packages_from_jessie"]  ||= []
    config["packages_from_stretch"] ||= []
    config["packages_from_buster"]  ||= []
    config["security_updates"]      ||= "0"
  }

  def parameters
    { "packages_from_squeeze" => config["packages_from_squeeze"],
      "packages_from_wheezy"  => config["packages_from_wheezy"],
      "packages_from_jessie"  => config["packages_from_jessie"],
      "packages_from_stretch" => config["packages_from_stretch"],
      "packages_from_buster" => config["packages_from_buster"]
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

  def packages_from_stretch=(packages)
    config["packages_from_stretch"] = packages.is_a?(String) ? packages.gsub(/ */,'').split(',') : packages
  end

  def packages_from_stretch
    config["packages_from_stretch"].join(', ') rescue ""
  end

  def packages_from_buster=(packages)
    config["packages_from_buster"] = packages.is_a?(String) ? packages.gsub(/ */,'').split(',') : packages
  end

  def packages_from_buster
    config["packages_from_buster"].join(', ') rescue ""
  end

end
