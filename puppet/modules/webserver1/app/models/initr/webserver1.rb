class Initr::Webserver1 < Initr::Klass

  unloadable

  has_many :webserver1_domains, :dependent => :destroy, :class_name => "Initr::Webserver1Domain"
  belongs_to :node, :class_name => 'Initr::Node'
  validates_confirmation_of :password, :allow_nil => true
  validates_format_of :webserver_default_domain, :with => /http(|s):\/\/(.*)/, :on => :update 
  attr_accessor :password, :password_confirmation
  self.accessors_for(%w(accessible_phpmyadmin blowfish_secret manage_php allow_anonymous_ftp manage_default_domain))

  def initialize(attributes=nil)
    super
    config["admin_password"] ||= ""
    config["accessible_phpmyadmin"] ||= "0"
    config["blowfish_secret"] ||= ""
    config["manage_php"] ||= "1"
    config["allow_anonymous_ftp"] ||= "0"
    config["manage_default_domain"] ||= "1"
  end

  def before_validation
    self.admin_password = password unless password.blank? or password != password_confirmation
  end

  def name
    "webserver1"
  end

  def parameters
    domain_list = {}
    tags_for_sshkey = []
    webserver1_domains.each do |domain|
      domain_list[domain.name] = domain.parameters
      if domain.web_backups_server
        tags_for_sshkey << "#{domain.web_backups_server.address}_web_backups_client"
      end
    end
    tags_for_sshkey.uniq!
    { "webserver_domains"=>domain_list,
      "admin_password"=>config["admin_password"],
      "accessible_phpmyadmin"=>accessible_phpmyadmin,
      "blowfish_secret"=>blowfish_secret,
      "manage_php"=>manage_php,
      "allow_anonymous_ftp"=>allow_anonymous_ftp,
      "webserver_default_domain"=>webserver_default_domain,
      "tags_for_sshkey"=>tags_for_sshkey,
      "manage_default_domain"=>manage_default_domain }
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

  def admin_password
    config["admin_password"].nil? ? "" : "*"*config["admin_password"].size
  end
  def admin_password=(p)
    config["admin_password"]=p
  end 

  def webserver_default_domain
    config["webserver_default_domain"] ||= webserver1_domains.any? ? "http://www.#{webserver1_domains.first.name}" : "http://#{Setting.host_name}"
  end
  def webserver_default_domain=(v)
    config["webserver_default_domain"]=v
  end
  
  def self.backup_servers_for_current_user
    user_projects = User.current.projects
    Initr::WebBackupsServer.all.collect { |bs|
      bs if user_projects.include? bs.node.project
    }.compact
  end

  def clone
    copy = Initr::Webserver1.new(self.attributes)
    self.webserver1_domains.each do |ws|
      ws_copy = ws.clone
      ws_copy.webserver1_id=nil
      ws_copy.web_backups_server_id=nil
      copy.webserver1_domains << ws_copy
    end
    copy
  end

end
