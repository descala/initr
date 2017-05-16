class Initr::Nagios < Initr::Klass


  has_many :nagios_checks, :dependent => :destroy, :class_name => "Initr::NagiosCheck"
  belongs_to :nagios_server, :class_name => "Initr::NagiosServer", :foreign_key => "klass_id"

  after_create :create_all_default_checks

  attr_accessible :klass_id

  def puppetname
    "nagios::nsca_node"
  end

  def parameters
    raise Initr::Klass::ConfigurationError.new("nagios_server not configured") if nagios_server.nil?
    checks = {}
    nagios_checks.each do |nc|
      checks[nc.name] = nc.puppetconf unless nc.puppetconf.nil?
    end
    p = {
      "nagios_checks" => checks,
      "nagios_server" => nagios_server.address,
      "nsca_decryption_password" => nagios_server.nsca_decryption_password
    }
    p["nagios_contact_groups"]=nagios_contact_groups if nagios_contact_groups
    return p
  end

  def print_parameters
    checks=active_checks.collect {|c| c.name }.to_sentence
    return checks
  end

  def config
    return {} if super.nil?
    super
  end

  def active_checks
    (nagios_checks.collect {|c| c unless c.ensure == "absent" }).compact.sort
  end

  def inactive_checks
    (nagios_checks.collect {|c| c if c.ensure == "absent" }).compact.sort
  end

  # Other klasses can define nagios_checks with "default_nagios_checks" method
  # it must return a hash with { "name" => "command" } like this class does
  def recomended_checks
    rc = {}
    self.node.klasses.each do |k|
      rc = rc.merge(k.default_nagios_checks) if k.respond_to? "default_nagios_checks"
    end
    self.active_checks.each do |ac|
      rc.delete_if {|name,command| command == ac.command or name == ac.name }
    end
    rc
  end

  def default_nagios_checks
    dc = {}
    dc["load"]   = "check_load -w 5,4,2 -c 8,6,4"
    dc["df"]     = "check_disk -W 10\% -K 5\% -w 10\% -c 5\% -p /"
    dc["ssh"]    = "check_ssh -H localhost"
    dc["swap"]   = 'check_swap -w 25\% -c 5\%'
    dc
  end

  # per defecte nomes assignem el contactgroup dels administradors,
  # si te usuaris que puguin rebre alertes
  def nagios_contact_groups
    proj = self.node.project
    return nil unless proj.active?
    allowed_roles = Role.all.collect {|r| r if r.has_permission?(:nagios_alerts)}.compact
    proj.users.each do |user|
      allowed_roles_for_user = allowed_roles - (allowed_roles - user.roles_for_project(proj))
      return proj.identifier if allowed_roles_for_user.collect {|r| r.id}.include? 3
    end
    return nil
  end

  private

  def create_all_default_checks
    default_checks = self.recomended_checks
    default_checks.each do |name,command|
      check = Initr::NagiosCheck.new
      check.name = name
      check.command = command
      check.nagios = self
      check.save
    end
  end

end
