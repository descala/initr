class Initr::Samba < Initr::Klass

  validates_inclusion_of :smbmode, :in => %w( samba samba::ldap_pdc ),:on => :update
  self.accessors_for %w(smbmode smbdomain ldappasswd smbdir netlogon_script nagios_smbuser nagios_smbpass)

  after_initialize {
    config["smbmode"]         ||= "samba"
    config["smbdir"]          ||= "/var/arxiver"
    config["netlogon_script"] ||= "%U.cmd"
  }

  def parameters
    raise Initr::Klass::ConfigurationError.new("Missing smbmode") unless smbmode
    super
  end

  def puppetname
    smbmode
  end

end
