require File.dirname(__FILE__) + '/../../../test_helper'

class Initr::PluginTest < Test::Unit::TestCase

  def setup
    @klass = Initr::Plugin
    # In case some real plugins are installed
    @klass.clear
  end
  
  def teardown
    @klass.clear
  end
  
  def test_register
    @klass.register :foo do
      klasses :apache2 => 'Manages apache 2', :apache1 => 'Manages apache 1'
      redmine do
        name 'Foo plugin'
        url 'http://example.net/plugins/foo'
        author 'John Smith'
        author_url 'http://example.net/jsmith'
        description 'This is a test plugin'
        version '0.0.1'
      end
    end
    
    assert_equal 1, @klass.all.size
    
    plugin = @klass.find('foo')
    assert plugin.is_a?(Initr::Plugin)
    assert_equal({:apache2 => 'Manages apache 2', :apache1 => 'Manages apache 1'}, plugin.klasses)

    plugin = Redmine::Plugin.find('foo')
    assert plugin.is_a?(Redmine::Plugin)
    assert_equal :foo, plugin.id
    assert_equal 'Foo plugin', plugin.name
    assert_equal 'This is a test plugin', plugin.description
    assert_equal '0.0.1', plugin.version
  end

  def test_klass_names
    @klass.register :foo do
      klasses :apache2 => 'Manages apache 2', :apache1 => 'Manages apache 1'
    end
    @klass.register :bar do
      klasses :bar => 'Bar class'
    end
    
    assert_equal 3, @klass.klass_names.size
    assert @klass.klass_names.first.is_a?(Initr::KlassName)
  end
  

end
