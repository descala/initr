class Initr::Rsyncd < Initr::Klass

  self.accessors_for([:modules,:secrets])

  def parameters
    { "rsyncd_modules" => self.modules, "rsyncd_secrets" => self.secrets }
  end

  after_initialize {
    config["modules"] ||= "#[test]
#  path = /path/to/directory
#  auth users = user
#  read only = no"
    config["secrets"] ||= "#user:password"
  }

end
