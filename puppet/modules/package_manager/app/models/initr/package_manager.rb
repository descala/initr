class Initr::PackageManager < Initr::Klass
  unloadable

  self.accessors_for(["security_updates","packages_from_squeeze"])

  def initialize(attributes=nil)
    super
    config["packages_from_squeeze"] ||= ["puppet","rubygems","rubygems1.8"]
    config["packages_from_wheezy"]  ||= []
  end

end
