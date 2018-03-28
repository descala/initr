class Initr::Monit < Initr::Klass

  attr_accessible :monit_checks

  after_initialize {
    self.monit_checks ||= []
    self.apache_path  ||= ""
  }

  def name
    "monit"
  end

  def print_parameters
    return "-" if monit_checks.size == 0
    "Monit checks: #{monit_checks.join(", ")}"
  end

  def monit_checks
    config["monit_checks"]
  end

  def monit_checks=(checks)
    config["monit_checks"]=checks
  end

  def apache_path
    config["apache_path"]
  end

  def apache_path=(v)
    config["apache_path"]=v
  end

end
