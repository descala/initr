require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class NodeTest < ActiveSupport::TestCase

  fixtures 'initr/nodes', 'puppet/rails/hosts', 'puppet/rails/fact_names', 'puppet/rails/fact_values'

  test "node facts" do
    node = initr_nodes(:node_001)
    assert_equal "node_001", node.name
    host = node.puppet_host 
    assert_equal "node_001", host.name
    assert_equal "google-public-dns-a.google.com", host.get_facts_hash['fqdn'].first.value
    assert_equal "google-public-dns-a.google.com", node.puppet_fact('fqdn')
  end
  
end

