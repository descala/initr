class Initr::Fail2ban < Initr::Klass

  unloadable
  # simple getters and setters for serialized attributes
  self.accessors_for(%w(mailto custom_jails))

  # set some defaults
  after_initialize {
    self.mailto       ||= ""
    self.jails        ||= {}
    self.custom_jails ||=""
  }

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

  # custom setter for serialized attribute
  def jails=(jails)
    config["jails"]=jails.keys
  end

end
