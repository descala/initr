class Initr::Fail2ban < Initr::Klass
  unloadable

  def initialize(attributes=nil)
    super
    self.mailto ||= ""
    self.fail2ban_jails ||= {}
  end

  def name
    "fail2ban"
  end

  def print_parameters
    return super if fail2ban_jails.size == 0
    "Active jails: #{fail2ban_jails.join(', ')}"
  end

  def fail2ban_jails
    self.config["fail2ban_jails"]
  end

  def fail2ban_jails=(jails)
    self.config["fail2ban_jails"]=jails.keys
  end

  def mailto
    self.config["mailto"]
  end

  def mailto=(mail)
    self.config["mailto"]=mail
  end

end
