class Initr::Webserver1 < Initr::Klass

  unloadable

  has_many :webserver1_domains, :dependent => :destroy, :class_name => "Initr::Webserver1Domain"
  belongs_to :node, :class_name => 'Initr::Node'
  validates_confirmation_of :password, :allow_nil => true
  attr_accessor :password, :password_confirmation

  def initialize(attributes=nil)
    super
    admin_password ||= ""
    accessible_phpmyadmin ||= "0"
    blowfish_secret ||= ""
  end

  def before_validation
    self.admin_password = password unless password.blank? or password != password_confirmation
  end

  def name
    "webserver1"
  end

  def parameters
    domain_list = {}
    bind_masterzones = {}
    webserver1_domains.each do |domain|
      domain_list[domain.name] = domain.parameters
      bind_masterzones[domain.name] = domain.bind_parameters unless domain.bind_parameters.nil?
    end
    { "webserver_domains"=>domain_list,
      "bind_masterzones"=>bind_masterzones,
      "admin_password"=>config["admin_password"],
      "accessible_phpmyadmin"=>accessible_phpmyadmin,
      "blowfish_secret"=>blowfish_secret }
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
    webserver1_domains
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

  def admin_password
    config["admin_password"].nil? ? "" : "*"*config["admin_password"].size
  end
  def admin_password=(p)
    config["admin_password"]=p
  end 

  def accessible_phpmyadmin
    config["accessible_phpmyadmin"]
  end
  def accessible_phpmyadmin=(v)
    config["accessible_phpmyadmin"]=v
  end

  def blowfish_secret
    config["blowfish_secret"]
  end
  def blowfish_secret=(v)
    config["blowfish_secret"]=v
  end

  def self.backup_servers_for_current_user
    user_projects = User.current.projects
    Initr::WebBackupsServer.all.collect { |bs|
      bs if user_projects.include? bs.node.project
    }.compact
  end

end
