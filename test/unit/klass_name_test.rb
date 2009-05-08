require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

Engines::Testing.set_fixture_path

class KlassNameTest < Test::Unit::TestCase

  fixtures :klass_names
  
  def test_use_of_fixtures
    #    assert_equal klass_names(:simpleklass), KlassName.first(:name=>'simpleklass')
  end
  
end
