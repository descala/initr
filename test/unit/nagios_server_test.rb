require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

# Icinga refuses to start when an object points at a contact group that is not
# defined. Who points at a group and who defines it are decided in different
# places and applied at different times:
#
# * a node's exported Nagios_host / Nagios_service carry "contact_groups" and
#   only change when that node runs Puppet again;
# * the server defines the groups (Initr::NagiosServer#nagios_contactgroups)
#   and changes on its very next run.
#
# So the server must keep defining every group that is still referenced, even
# when the project behind it has no nodes left.
class NagiosServerTest < ActiveSupport::TestCase

  fixtures 'initr/nodes'

  ADDRESS = 'monitor.example.com'

  # Stand-in for PuppetDB::Client: answers the two exported resource queries.
  class FakePuppetdb
    Response = Struct.new(:data)

    def initialize(hosts: [], services: [])
      @hosts = hosts
      @services = services
    end

    def request(_endpoint, query)
      return Response.new(@hosts)    if query.include?("'Nagios_host'") and !query.include?('certname')
      return Response.new(@services) if query.include?("'Nagios_service'")
      Response.new([])
    end
  end

  def setup
    # the admin role is hardcoded as id 3 in the nagios module
    @admin_role = Role.find(3)
    @admin_role.add_permission!(:nagios_alerts)

    @server = Initr::NagiosServer.new
    @server.config = { 'address' => ADDRESS }

    @project = Project.generate!
    @user = User.generate!
    User.add_to_project(@user, @project, @admin_role)
  end

  def exported(type, title, contact_groups, tag = ADDRESS)
    { 'type' => type, 'title' => title,
      'parameters' => { 'contact_groups' => contact_groups, 'tag' => tag, 'host_name' => title } }
  end

  def puppetdb_exports(hosts: [], services: [])
    Initr.stubs(:puppetdb).returns(FakePuppetdb.new(hosts: hosts, services: services))
  end

  # moves the fixture node; update_column skips the puppetrun callbacks
  def add_node_to(project)
    initr_nodes(:node_001).update_column(:project_id, project.id)
  end

  test "a project with nodes gets its contact group and contacts" do
    puppetdb_exports
    add_node_to(@project)
    assert_equal @user.login, @server.nagios_contactgroups[@project.identifier]['members']
    assert_includes @server.nagios_contacts.keys, @user.login
  end

  test "a project with no nodes and no references gets no contact group" do
    puppetdb_exports
    refute_includes @server.nagios_contactgroups.keys, @project.identifier
    refute_includes @server.nagios_contacts.keys, @user.login
  end

  # A node was moved to another project and has not run Puppet since: its
  # exported host still names the old project's group.
  test "a project with no nodes keeps its group while an exported host references it" do
    puppetdb_exports(:hosts => [exported('Nagios_host', 'host1.example.com', @project.identifier)])
    assert_includes @server.nagios_contactgroups.keys, @project.identifier
    assert_includes @server.nagios_contacts.keys, @user.login
  end

  test "a project with no nodes keeps its group while an exported service references it" do
    puppetdb_exports(:services => [exported('Nagios_service', 'host1.example.com_load', @project.identifier)])
    assert_includes @server.nagios_contactgroups.keys, @project.identifier
    assert_includes @server.nagios_contacts.keys, @user.login
  end

  test "references exported for another nagios server are ignored" do
    puppetdb_exports(:hosts => [exported('Nagios_host', 'host1.example.com', @project.identifier, 'other.example.com')])
    refute_includes @server.nagios_contactgroups.keys, @project.identifier
  end

  # The templates point every generic object at admin_contactgroup, so the
  # group has to exist whether or not its project has nodes.
  test "the admin contactgroup project gets its group even with no nodes" do
    puppetdb_exports
    @server.config['admin_contactgroup'] = @project.identifier
    assert_includes @server.nagios_contactgroups.keys, @project.identifier
    assert_equal @project.identifier, @server.admin_contactgroup
  end

  test "admin_contactgroup is nil when its group cannot be defined" do
    puppetdb_exports
    @user.update_column(:status, User::STATUS_LOCKED)
    @server.config['admin_contactgroup'] = @project.identifier
    refute_includes @server.nagios_contactgroups.keys, @project.identifier
    assert_nil @server.admin_contactgroup
  end

end
