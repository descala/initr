class Initr::NagiosServer < Initr::Klass
  has_many :nagios, :class_name => "Initr::Nagios", :foreign_key => "klass_id"
  validates_presence_of :address, :on => :update
  validates_presence_of :nagiosadmin_password, :on => :update
  validates_confirmation_of :password, :allow_nil => true
  validate :admin_contactgroup_belongs_to_user
  before_validation :set_password

  self.accessors_for(["address","nagiosadmin_password",
                      "nsca_decryption_password","admin_contactgroup",
                      "nagios_webserver"])

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
      "admin_contactgroup" => admin_contactgroup,
      "nagios_webserver" => nagios_webserver }
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
      next unless needs_contactgroups?(project)
      allowed_roles.each do |role|
        project.users.collect do |user|
          contacts[user.login] = {
            'email' => user.mail,
            # https://tickets.puppetlabs.com/browse/PUP-3368
            'nagiosalias' => user.name.to_s.gsub(/\P{ASCII}/, '')
          } if user.roles_for_project(project).include?(role) and user.active?
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
      nagios_users[username] = username.crypt('asdfsecret')
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
      next unless needs_contactgroups?(p)
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

  # The templates point every generic object at this group, so it is only
  # returned when nagios_contactgroups really defines it: the project is active
  # and has an admin user with nagios_alerts permission.
  def admin_contactgroup
    group = config["admin_contactgroup"]
    group if group.present? and nagios_contactgroups.key?(group)
  end

  # nagios_hostgroups:
  #   project:
  #      nagiosalias: A project
  #      hostgroup_members: host1.example.com, host2.example.com
  def nagios_hostgroups
    groups = {}
    Project.all.each do |p|
      next unless p.active?
      members = nagios_hosts_for(p).join(', ')
      next if members.blank?
      groups[p.identifier] = {
        # https://tickets.puppetlabs.com/browse/PUP-3368
        'nagiosalias' => p.name.to_s.gsub(/\P{ASCII}/, ''),
        'members' => members
      }
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

  # Icinga refuses to start if any object names a contact group that is not
  # defined, so a project's groups (and their contacts) must exist for as long
  # as something points at them, not only while the project has nodes.
  def needs_contactgroups?(project)
    return false unless project.active?
    project.nodes.size > 0 or referenced_contact_groups.include?(project.identifier)
  end

  # Contact group names the Icinga config points at from outside this class:
  #
  # * admin_contactgroup, used by the templates;
  # * "contact_groups" of the Nagios_host / Nagios_service resources the nodes
  #   export (Initr::Nagios#nagios_contact_groups). Those only change when the
  #   node itself runs Puppet again, so after a node moves to another project
  #   they keep naming the old project's group for a while, or for good if the
  #   node no longer runs Puppet.
  def referenced_contact_groups
    @referenced_contact_groups ||= begin
      groups = [config["admin_contactgroup"]]
      (exported_nagios_resources('Nagios_host') + exported_nagios_resources('Nagios_service')).each do |r|
        groups.concat r['parameters']['contact_groups'].to_s.split(',').collect(&:strip)
      end
      groups.reject(&:blank?).uniq
    end
  end

  # Exported resources of a type tagged for this server. One PuppetDB query per
  # type, memoized: hostgroups, escalations and contact groups all need them.
  def exported_nagios_resources(type)
    @exported_nagios_resources ||= {}
    @exported_nagios_resources[type] ||= begin
      exported = Initr.puppetdb.request('', "resources {type = '#{type}' and exported = true }").data rescue []
      exported.select { |r| r['parameters']['tag'] == address }
    end
  end

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

  # for a project, return the host names of all "Nagios_host" exported resources with the
  # server tag, exactly as nagios_host.cfg spells them.
  # if we return here a host that is not defined in nagios_host.cfg, nagios will fail to restart
  #
  # All matching exports count, not just the first: a node running nagios::check_router
  # exports both "<fqdn>" and "<fqdn>_router", and which one comes back first is arbitrary.
  #
  # Only hosts that actually have a service are returned. The project's serviceescalation
  # uses service_description "*", and Icinga cannot expand that for a member with no
  # services: "Could not expand services specified in service escalation" and the daemon
  # refuses to start. nagios::check_router exports a generic-switch host and no services at
  # all, so "<fqdn>_router" must stay out of the group.
  def nagios_hosts_for(proj)
    members = []
    with_services = nagios_hosts_with_services
    proj.nodes.each do |n|
      exported_resources = Initr.puppetdb.request('', "resources {certname = '#{n.name}' and type = 'Nagios_host' and exported = true }").data rescue {}
      if exported_resources.empty?
        # try with ActiveRecord instead of PuppetDB
        next unless n.is_a? Initr::NodeInstance
        next if n.puppet_host.nil?
        exported_resources = n.puppet_host.resources.where("exported=true and restype='Nagios_host'")
        exported_resources.each do |r|
          if r.puppet_tags.collect {|pt| pt.name}.include?(address) and with_services.include?(r.title)
            members << r.title
          end
        end
      else
        exported_resources.each do |r|
          members << r['title'] if r['parameters']['tag'] == address and with_services.include?(r['title'])
        end
      end
    end
    members.uniq
  end

  # host_names that have at least one exported Nagios_service tagged for this server, i.e.
  # the hosts that will actually have services in nagios_service.cfg.
  def nagios_hosts_with_services
    exported_nagios_resources('Nagios_service').collect do |r|
      r['parameters']['host_name']
    end.compact.uniq
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
      errors.add :base, l(:invalid_admin_contactgroup)
    end
  end
end
