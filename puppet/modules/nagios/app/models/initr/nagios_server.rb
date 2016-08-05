class Initr::NagiosServer < Initr::Klass


  has_many :nagios, :class_name => "Initr::Nagios", :foreign_key => "klass_id"
  validates_presence_of :address, :on => :update
  validates_presence_of :nagiosadmin_password, :on => :update
  validates_confirmation_of :password, :allow_nil => true
  validate :admin_contactgroup_belongs_to_user
  before_validation :set_password
  attr_accessor :password, :password_confirmation
  attr_accessible  :password, :password_confirmation

  self.accessors_for(["address","nagiosadmin_password","nsca_decryption_password","admin_contactgroup"])

  def set_password
    self.nagiosadmin_password = password.crypt(random_string(2)) unless password.blank?
  end

  def configurable?
    false
  end

  def name
    "nagios::server"
  end

  def admin_contactgroup=(v)
    config["admin_contactgroup"]=(v)
  end

  def parameters
    { "nagios_contacts" => nagios_contacts,
      "nagios_contactgroups" => nagios_contactgroups,
      "nagios_hostgroups" => nagios_hostgroups,
      "nagios_hostescalations" => nagios_hostescalations,
      "nagios_serviceescalations" => nagios_serviceescalations,
      "nagios_address" => address,
      "nagiosadmin_password" => nagiosadmin_password,
      "nagios_users" => nagios_users,
      "nsca_decryption_password" => nsca_decryption_password,
      "admin_contactgroup" => admin_contactgroup }
  end

  def print_parameters
    "All projects and users are added as Nagios contacts"
  end

  # nagios_contacts:
  #   name:
  #      email: name@example.com
  #      nagiosalias: Name Surname
  #   lluis: ...
  def nagios_contacts
    contacts = {}
    allowed_roles = Role.all.collect do |role|
      role if role.has_permission?(:nagios_alerts)
    end.compact
    Project.all.each do |project|
      next unless project.active?
      next unless project.nodes.size > 0
      allowed_roles.each do |role|
        project.users.collect do |user|
          contacts[user.login] = { 'email' => user.mail, 'nagiosalias' => user.name } if user.roles_for_project(project).include?(role) and user.active?
        end
      end
    end
    contacts
  end

  # nagios_users:
  #   username1: password1
  #   username2: password2
  #   ...
  def nagios_users
    nagios_users = {}
    nagios_contacts.keys.collect do |username|
      # WARNING
      # TODO passwords are usernames TODO
      # WARNING
      nagios_users[username] = username.crypt(random_string(2))
    end
    nagios_users
  end

  # nagios_contactgroups:
  #   group:
  #      nagiosalias: Nagios notifications group
  #      members: name, name2
  def nagios_contactgroups
    ncgs = {}
    allowed_roles = Role.all.collect { |r|
      r if r.has_permission?(:nagios_alerts)
    }.compact
    Project.all.each do |p|
      next unless p.active?
      next unless p.nodes.size > 0
      allowed_roles.each do |r|
        logins = p.users.collect do |u|
          u.login if u.roles_for_project(p).include?(r) and u.active?
        end.compact
        next unless logins.size > 0
        if r.id == 3 # admin role
          ncgs[p.identifier] = { 'nagiosalias' => "#{p.identifier}#{r.id}", 'members' => logins.join(', ') }
        else
          ncgs["#{p.identifier}#{r.id}"] = { 'nagiosalias' => "#{p.identifier}_#{r.name}", 'members' => logins.join(', ') }
        end
      end
    end
    ncgs
  end

  def admin_contactgroup
    if config["admin_contactgroup"]
      proj = Project.find_by_identifier(config["admin_contactgroup"])
      return nil unless proj and proj.active?
      allowed_roles_for_project_users(proj) do |role|
        # return admin_contactgroup only if has an admin user with
        # nagios_alerts permission
        return config["admin_contactgroup"] if role.id == 3
      end
    end
    return nil
  end

  # nagios_hostgroups:
  #   project:
  #      nagiosalias: A project
  #      hostgroup_members: host1.example.com, host2.example.com
  def nagios_hostgroups
    groups = {}
    Project.all.each do |p|
      next unless p.active?
      members = nagios_hosts_for(p).collect {|n| n.fqdn }.join(', ')
      next if members.blank?
      groups[p.identifier] = { 'nagiosalias' => p.name ,'members' => members }
    end
    groups
  end

  # nagios_hostescalations:
  #   group1_all:
  #     last_notification: 2
  #     contact_groups: group1,group18
  #     notification_interval: 720
  #     first_notification: 2
  #     hostgroup_name: group1
  #   group1_group1:
  #     last_notification: 0
  #     contact_groups: group1
  #     notification_interval: 720
  #     first_notification: 3
  #     hostgroup_name: group1
  #
  def nagios_hostescalations
    nhe = {}
    Project.all.each do |p|
      next unless p.active?
      next unless nagios_hosts_for(p).size > 0
      all_contact_groups = allowed_roles_for_project_users(p) do |role|
        if role.id == 3 # admin role
          p.identifier
        else
          "#{p.identifier}#{role.id}"
        end
      end
      # 1st notification is sent to admin contactgroup, since it has no notification escalation defined.
      # 2nd notification we create escalation to notify every contactgroup every 12h.
      # The escalation code is smart enough to realize that only those people
      # who were notified about the problem should be notified about the recovery
      if all_contact_groups.any?
        nhe[p.identifier+"_all"] = { 'hostgroup_name'        => p.identifier,
                                     'contact_groups'        => all_contact_groups.uniq.join(","),
                                     'first_notification'    => 2,
                                     'last_notification'     => 0,
                                     'notification_interval' => 720 # 12h
        }
      end
    end
    nhe
  end

  # nagios_serviceescalations:
  #   group1_all:
  #     last_notification: 2
  #     contact_groups: group1,group18
  #     notification_interval: 720
  #     first_notification: 2
  #     hostgroup_name: group1
  #     service_description: *
  #   group1_group1:
  #     last_notification: 0
  #     contact_groups: group1
  #     notification_interval: 720
  #     first_notification: 3
  #     hostgroup_name: group1
  #     service_description: *
  #
  def nagios_serviceescalations
    nse = {}
    Project.all.each do |p|
      next unless p.active?
      next unless nagios_hosts_for(p).size > 0
      all_contact_groups = allowed_roles_for_project_users(p) do |role|
        if role.id == 3 # admin role
          p.identifier
        else
          "#{p.identifier}#{role.id}"
        end
      end
      # serviceescalations work like hostescalation, read above
      if all_contact_groups.any?
        nse[p.identifier+"_all"] = { 'hostgroup_name'        => p.identifier,
                                     'contact_groups'        => all_contact_groups.uniq.join(","),
                                     'first_notification'    => 2,
                                     'last_notification'     => 0,
                                     'notification_interval' => 720, # 12h
                                     'service_description'   => "*"
        }
      end
    end
    nse
  end

  private

  def allowed_roles_for_project_users(project)
    ret = []
    allowed_roles = Role.all.collect {|r| r if r.has_permission?(:nagios_alerts)}.compact
    project.users.each do |user|
      next unless user.active?
      allowed_roles_for_user = allowed_roles - (allowed_roles - user.roles_for_project(project))
      allowed_roles_for_user.each do |role|
        ret << yield(role)
      end
    end
    ret
  end

  # for a project, return all nodes with a "Nagios_host" exported resource with the server tag
  # if we return here a host that is not defined in nagios_host.cfg, nagios will fail to restart
  def nagios_hosts_for(proj)
    members = []
    proj.nodes.collect do |n|
      next if n.puppet_host.nil?
      # check that node has a Nagios_host exported resource with server tag
      exported_resources = n.puppet_host.resources.where("exported=true and restype='Nagios_host'")
      exported_resources.each do |r|
        if r.puppet_tags.collect {|pt| pt.name}.include? address
          members << n
        end
      end
    end
    members
  end

  RAND_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" +
    "0123456789" +
    "abcdefghijklmnopqrstuvwxyz"

  def random_string(len)
    rand_max = RAND_CHARS.size
    ret = ""
    len.times{ ret << RAND_CHARS[rand(rand_max)] }
    ret
  end

  def admin_contactgroup_belongs_to_user
    return true if User.current.admin? or config["admin_contactgroup"].blank?
    unless User.current.projects.collect {|p| p.identifier}.include?(config["admin_contactgroup"])
      errors.add_to_base l(:invalid_admin_contactgroup)
    end
  end

end
