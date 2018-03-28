require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class MuninTest < Test::Unit::TestCase

  def setup
  end

  def teardown
  end

  def test_config_serialize
    munin = Initr::Munin.new
    check = Initr::MuninCheck.new()
    check.plugin="test"
    check.active=true
    munin.config = [check]
    munin.save
    retrieved = Initr::Munin.find munin.id
    assert_equal 1, retrieved.config.size
    assert_equal "test", retrieved.config.first.plugin
    assert retrieved.config.first.active
  end

  def test_server_node_relation
    node1 = Initr::Munin.new
    node2 = Initr::Munin.new
    server = Initr::MuninServer.new
    server.save
    assert_equal 0, server.nodes.size
    node1.server=server
    assert_equal server.id, node1.server.id
    node2.server=server
    assert_equal server.id, node2.server.id
    server = Initr::MuninServer.find server.id
    assert_equal 2, server.nodes.size
  end

end
