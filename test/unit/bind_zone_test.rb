require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

# Guards the records-body sanitisation on Initr::BindZone. The "My DNS"
# self-service surface lets a low-privilege (:edit_own_bind_zones) user edit a
# zone's records body, which is written to a file and parsed by named-checkzone.
# The master-file directive $INCLUDE would make that parser open an arbitrary
# file on the host and echo fragments of it back in the validation error
# (authenticated file-read / info disclosure); $GENERATE can exhaust resources.
# reject_master_file_directives must refuse such a body, and named_checkzone
# must never even spawn the checker on it.
class BindZoneTest < ActiveSupport::TestCase

  fixtures 'initr/nodes', 'initr/klasses', 'initr/bind_zones'

  def setup
    @zone = initr_bind_zones(:bind_zone_001)
  end

  # Every spelling named-checkzone honors (case-insensitive), plus indented and
  # not-first-line forms we reject for defence in depth (broader than the parser
  # is safe — narrower would be a bypass).
  FORBIDDEN_BODIES = {
    'uppercase $INCLUDE'           => '$INCLUDE /etc/passwd',
    'lowercase $include'           => '$include /etc/passwd',
    'mixed-case $InClUdE'          => '$InClUdE /etc/passwd',
    'indented $INCLUDE'            => '   $INCLUDE /etc/passwd',
    '$INCLUDE after a valid record'=> "www IN A 1.2.3.4\n$INCLUDE /etc/passwd",
    '$GENERATE'                    => '$GENERATE 1-9 host$ A 10.0.0.$',
  }

  FORBIDDEN_BODIES.each do |label, body|
    test "rejects a records body with #{label}" do
      @zone.zone = body
      refute @zone.valid?, "expected #{label} to be rejected"
      assert @zone.errors[:zone].any? { |m| m =~ /INCLUDE|GENERATE|directive/i },
             "expected a control-directive error on :zone, got #{@zone.errors[:zone].inspect}"
    end
  end

  test "named-checkzone is never spawned for a forbidden body (no file read can fire)" do
    @zone.zone = '$INCLUDE /etc/passwd'
    # named_checkzone is the only validation-path caller of Open3.capture2e; if
    # the guard regressed, the checker would run and this expectation would fail.
    Open3.expects(:capture2e).never
    refute @zone.valid?
  end

  test "a legitimate records body with a $ inside record data is not treated as a directive" do
    # Isolate from the external checker so the test asserts only the directive
    # filter: with no binary located, named_checkzone is a no-op.
    @zone.stubs(:named_checkzone_bin).returns(nil)
    @zone.zone = 'txt IN TXT "price is $5 today"'
    assert @zone.valid?, @zone.errors.full_messages.join(', ')
    assert_empty @zone.errors[:zone]
  end
end
