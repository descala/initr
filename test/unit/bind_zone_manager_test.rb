require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

# Covers the per-zone ownership model (Initr::BindZoneManager) and the
# authorization predicate Initr::BindZone#editable_by? that gates both the
# "My DNS" self-service surface and (later) the DNS API.
class BindZoneManagerTest < ActiveSupport::TestCase

  fixtures 'initr/nodes', 'initr/klasses', 'initr/bind_zones'

  def setup
    @zone    = initr_bind_zones(:bind_zone_001)
    @admin   = User.find(1) # admin — bypasses all checks
    @project = @zone.bind.node.project # project 2, has the :initr module enabled
  end

  test "managers association links users to a zone" do
    user = User.generate!
    @zone.managers << user
    assert_includes @zone.reload.managers, user
  end

  test "editable_by? is true for an admin" do
    assert @zone.editable_by?(@admin)
  end

  test "editable_by? is true for a project member with edit_klasses" do
    user = User.generate!
    role = Role.generate!(:permissions => [:edit_klasses])
    User.add_to_project(user, @project, role)
    assert @zone.editable_by?(user.reload)
  end

  test "editable_by? is false for a user with no rights and no ownership" do
    refute @zone.editable_by?(User.generate!)
  end

  test "editable_by? is true for a manager holding edit_own_bind_zones (no project membership)" do
    user = User.generate!
    role = Role.generate!(:permissions => [:edit_own_bind_zones])
    # Member of a DIFFERENT project — proves ownership is independent of the
    # zone's project. The global :edit_own_bind_zones grant + manager link suffice.
    User.add_to_project(user, Project.find(1), role)
    @zone.managers << user
    assert @zone.reload.editable_by?(user.reload)
  end

  test "editable_by? is false for a manager who lacks edit_own_bind_zones" do
    user = User.generate!
    @zone.managers << user
    refute @zone.reload.editable_by?(user.reload)
  end

  test "destroying a zone removes its manager links" do
    user = User.generate!
    @zone.managers << user
    assert_difference 'Initr::BindZoneManager.count', -1 do
      @zone.destroy
    end
  end
end
