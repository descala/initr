class Initr::Fail2ban < Initr::Klass

  unloadable

  # set some defaults
  def initialize(attributes=nil)
    super
    self.mailto ||= ""
    self.jails ||= {}
    self.custom_jails ||=""
  end

  # puppet class is named fail2ban
  def name
    "fail2ban"
  end

  # fail2ban don't need top scope vars
  def parameters
    {}
  end

  # here we define class scope variables
  # (parameterized class)
  def class_parameters
    config
  end

  # this will appear on klass list description
  def print_parameters
    return super if jails.size == 0
    "Active jails: #{jails.join(', ')}"
  end

  # getter for serialized attribute
  def jails
    config["jails"]
  end

  # setter for serialized attribute
  def jails=(jails)
    config["jails"]=jails.keys
  end

  # getter for serialized attribute
  def mailto
    config["mailto"]
  end

  # setter for serialized attribute
  def mailto=(mail)
    config["mailto"]=mail
  end

  def custom_jails
    config["custom_jails"]
  end

  def custom_jails=(v)
    config["custom_jails"]=v
  end

end
