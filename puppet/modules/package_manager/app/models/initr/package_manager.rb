class Initr::PackageManager < Initr::Klass
  unloadable

  self.accessors_for(["security_updates","packages_from_testing"])

  def initialize(attributes=nil)
    super
    config["packages_from_testing"] ||= ["puppet","rubygems","rubygems1.8"]
  end

end
