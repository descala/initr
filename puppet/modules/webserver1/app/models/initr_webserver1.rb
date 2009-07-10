class InitrWebserver1 < Initr::Klass

  unloadable

  has_many :initr_webserver1_domains
  belongs_to :node, :class_name => 'Initr::Node'

  def name
    "webserver1"
  end

  def parameters
    domain_list = {}
    bind_masterzones = {}
    initr_webserver1_domains.each do |domain|
      domain_list[domain.name] = domain.parameters
      bind_masterzones[domain.name] = domain.bind_parameters unless domain.bind_parameters.nil?
    end
    { "webserver_domains" => domain_list, "bind_masterzones" => bind_masterzones }
  end

  def print_parameters
    return "Not yet configured" if parameters.empty?
    str = ""
    self.domains.each { |d|
      str += "#{d.name}, "
    }
    str.chop.chop
  end

  def domains
    initr_webserver1_domains
  end

  def default_nagios_checks
    case self.node.puppet_fact("operatingsystem","")
    when "Debian":
      httpd_service = "apache2"
    else
      httpd_service = "httpd"
    end
    dnc = {}
    dnc["apache"] = "check_procs -C #{httpd_service} -w 1:50 -c 1:100"
    return dnc
  end
 
end
