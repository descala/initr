require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

# TODO this test should reside in puppet/modules/bind

class InitrTest < ActiveSupport::TestCase

  fixtures :nodes, :klasses, :bind_zones
  set_fixture_class :bind_zones => Initr::BindZone

  test "loads bind klass" do
    assert Initr::Bind.find(2)
    assert Initr::Bind.find(2).bind_zones
  end

  test "adds bind klass" do
    bind = Initr::Bind.find(2)
    new_zone = Initr::BindZone.new(:domain=>'sadf.com')
    bind.bind_zones << new_zone
    assert_equal 2, bind.bind_zones.count
  end

  test "increments zone serial" do
    bind_zone = bind_zones(:bind_zone_001)
    bind_zone.zone += "\n;"
    bind_zone.save!
    serial_before = bind_zone.serial
    bind_zone.zone += "\n;"
    bind_zone.save!
    assert_equal (serial_before.to_i + 1).to_s, bind_zone.serial
  end

  test "does not increment zone serial" do
    bind_zone = bind_zones(:bind_zone_001)
    serial_before = bind_zone.serial
    bind_zone.save!
    assert_equal bind_zone.serial.to_i, serial_before.to_i
  end
 
end

