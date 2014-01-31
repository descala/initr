require File.dirname(__FILE__) + '/../test_helper'

class Initr::PluginTest <  ActiveSupport::TestCase

  def setup
    @plugin = Initr::Plugin
    # In case some real plugins are installed
    @plugin.clear
  end
  
  def teardown
    @plugin.clear
  end
  
  def test_register
    @plugin.register :foo do
      klasses :apache2 => 'Manages apache 2', :apache1 => 'Manages apache 1'
      name 'Foo plugin'
      url 'http://example.net/plugins/foo'
      author 'John Smith'
      author_url 'http://example.net/jsmith'
      description 'This is a test plugin'
      version '0.0.1'
    end
    
    assert_equal 1, @plugin.all.size
    
    plugin = @plugin.find('foo')
    assert plugin.is_a?(Initr::Plugin)
    assert_equal({:apache2 => 'Manages apache 2', :apache1 => 'Manages apache 1'}, plugin.klasses)

    plugin = Initr::Plugin.find('foo')
    assert plugin.is_a?(Redmine::Plugin)
    assert_equal :foo, plugin.id
    assert_equal 'Foo plugin', plugin.name
    assert_equal 'This is a test plugin', plugin.description
    assert_equal '0.0.1', plugin.version
  end

  def test_klass_names
    @plugin.register :foo do
      klasses :apache2 => 'Manages apache 2', :apache1 => 'Manages apache 1'
    end
    @plugin.register :bar do
      klasses :bar => 'Bar class'
    end
    
    assert_equal 3, @plugin.klass_names.size
    assert @plugin.klass_names.first.is_a?(Initr::KlassDefinition)
  end
  

end
