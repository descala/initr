class Initr::Fail2ban < Initr::Klass

  unloadable

  # set some defaults
  def initialize(attributes=nil)
    super
    self.mailto ||= ""
    self.fail2ban_jails ||= {}
    self.fail2ban_custom_jails ||=""
  end

  # puppet class is named fail2ban
  def name
    "fail2ban"
  end

  # here we don't need to override because Klass method does the job.
  # parameters needed by puppet.
  #def parameters
  #  config
  #end

  # this will appear on klass list description
  def print_parameters
    return super if fail2ban_jails.size == 0
    "Active jails: #{fail2ban_jails.join(', ')}"
  end

  # getter for serialized attribute
  def fail2ban_jails
    config["fail2ban_jails"]
  end

  # setter for serialized attribute
  def fail2ban_jails=(jails)
    config["fail2ban_jails"]=jails.keys
  end

  # getter for serialized attribute
  def mailto
    config["mailto"]
  end

  # setter for serialized attribute
  def mailto=(mail)
    config["mailto"]=mail
  end

  def fail2ban_custom_jails
    config["fail2ban_custom_jails"]
  end

  def fail2ban_custom_jails=(v)
    config["fail2ban_custom_jails"]=v
  end

end
