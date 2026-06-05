require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

# Unit tests for the semantic DNS-record matching used by BindRecordsController:
# the Initr::DnsRecord parser and the controller's private zone-search helpers.
# No database is touched — the controller is given an in-memory stub zone — so
# this runs without fixtures.
class DnsRecordTest < ActiveSupport::TestCase
  DnsRecord = Initr::DnsRecord

  FakeZone = Struct.new(:zone, :domain)

  def parse(line, origin: 'domain.com', inherited_owner: '@')
    DnsRecord.parse(line, origin: origin, inherited_owner: inherited_owner)
  end

  def assert_equivalent(a, b, origin: 'domain.com')
    assert_equal parse(a, origin: origin), parse(b, origin: origin),
                 "expected #{a.inspect} to be equivalent to #{b.inspect}"
  end

  def refute_equivalent(a, b, origin: 'domain.com')
    refute_equal parse(a, origin: origin), parse(b, origin: origin),
                 "expected #{a.inspect} NOT to be equivalent to #{b.inspect}"
  end

  def controller_for(zone_text, domain = 'domain.com')
    c = BindRecordsController.new
    c.instance_variable_set(:@bind_zone, FakeZone.new(zone_text, domain))
    c
  end

  # --- parser: owner-name equivalence ------------------------------------------

  test "apex @ equals the zone FQDN" do
    assert_equivalent "@ A 1.2.3.4", "domain.com. A 1.2.3.4"
  end

  test "relative owner equals its FQDN form" do
    assert_equivalent "www A 5.6.7.8", "www.domain.com. A 5.6.7.8"
  end

  test "owner comparison is case-insensitive" do
    assert_equivalent "WWW A 5.6.7.8", "www A 5.6.7.8"
  end

  # --- parser: TTL / class are ignored -----------------------------------------

  test "leading TTL and class are ignored" do
    assert_equivalent "@ A 1.2.3.4", "@ 3600 IN A 1.2.3.4"
    assert_equivalent "@ A 1.2.3.4", "@ IN 3600 A 1.2.3.4"
  end

  test "whitespace and tabs do not matter" do
    assert_equivalent "@\tA\t1.2.3.4", "@   A   1.2.3.4"
  end

  # --- parser: rdata normalisation per type ------------------------------------

  test "CNAME relative target equals FQDN target" do
    assert_equivalent "ftp CNAME www", "ftp CNAME www.domain.com."
  end

  test "MX preference and exchange are compared" do
    assert_equivalent "@ MX 10 mail", "domain.com. MX 10 mail.domain.com."
    refute_equivalent "@ MX 10 mail", "@ MX 20 mail"
  end

  test "SRV fields and target are compared" do
    assert_equivalent "_sip._tcp SRV 10 20 5060 sip", "_sip._tcp SRV 10 20 5060 sip.domain.com."
    refute_equivalent "_sip._tcp SRV 10 20 5060 sip", "_sip._tcp SRV 10 20 5061 sip"
  end

  test "TXT character-strings concatenate; case is significant" do
    assert_equivalent '@ TXT "ab" "cd"', '@ TXT "abcd"'
    refute_equivalent '@ TXT "Hello"',   '@ TXT "hello"'
  end

  test "TXT semicolons inside quotes are not treated as comments" do
    r = parse('@ TXT "v=DKIM1; k=rsa; p=ABC"')
    assert_equal 'v=DKIM1; k=rsa; p=ABC', r.rdata
  end

  test "different rdata is not equivalent" do
    refute_equivalent "www A 1.1.1.1", "www A 2.2.2.2"
  end

  test "different type is not equivalent" do
    refute_equivalent "www A 1.2.3.4", "www CNAME other"
  end

  # --- parser: non-records ------------------------------------------------------

  test "blank, comment and unknown-type lines parse to nil" do
    assert_nil parse("")
    assert_nil parse("   ")
    assert_nil parse("; just a comment")
    assert_nil parse("www FROBNICATE whatever")
  end

  # --- controller: contains_record? over a multi-line zone ---------------------

  test "contains_record? matches across formatting and skips comments" do
    zone = "\t\tA 1.2.3.4\n" \
           "www\tA\t5.6.7.8\n" \
           ";ftp CNAME www\n" \
           "@ TXT \"v=spf1 ~all\"\n"
    c = controller_for(zone)

    assert c.send(:contains_record?, "domain.com. A 1.2.3.4"),       "indented apex A"
    assert c.send(:contains_record?, "www.domain.com. 300 IN A 5.6.7.8"), "relative w/ ttl+class"
    assert c.send(:contains_record?, '@ TXT "v=spf1 ~all"'),         "apex TXT"
    refute c.send(:contains_record?, "ftp CNAME www"),               "commented-out record"
    refute c.send(:contains_record?, "absent A 9.9.9.9"),            "absent record"
  end

  test "indented continuation line inherits the previous owner, not @" do
    zone = "mail A 1.2.3.4\n" \
           "\tMX 10 mail\n"   # belongs to "mail", not the apex
    c = controller_for(zone)
    assert c.send(:contains_record?, "mail MX 10 mail.domain.com.")
    refute c.send(:contains_record?, "@ MX 10 mail")
  end

  # --- controller: zone_without_record -----------------------------------------

  test "zone_without_record removes only the equivalent record" do
    zone = "www A 1.1.1.1\nwww A 2.2.2.2\n"
    c = controller_for(zone)
    new_zone, removed = c.send(:zone_without_record, "www.domain.com. A 1.1.1.1")
    assert_equal 1, removed
    assert_equal "www A 2.2.2.2", new_zone
  end

  test "zone_without_record keeps comments and blank lines" do
    zone = "; keep me\n\nwww A 1.1.1.1\n"
    c = controller_for(zone)
    new_zone, removed = c.send(:zone_without_record, "www A 1.1.1.1")
    assert_equal 1, removed
    assert_equal "; keep me\n\n", new_zone + "\n" # trailing newline normalised away
  end

  test "zone_without_record reports zero when nothing matches" do
    c = controller_for("www A 1.1.1.1\n")
    _new_zone, removed = c.send(:zone_without_record, "absent A 9.9.9.9")
    assert_equal 0, removed
  end

  # --- controller: zone_with_record --------------------------------------------

  test "zone_with_record appends without stripping leading apex indentation" do
    c = controller_for("\t\tA 1.2.3.4\n")
    result = c.send(:zone_with_record, "newhost A 5.6.7.8")
    assert result.start_with?("\t\tA 1.2.3.4"), "leading apex indentation preserved"
    assert result.end_with?("newhost A 5.6.7.8")
  end

  # --- controller: records_for_owner_type (update's match set) -----------------

  test "records_for_owner_type matches owner+type across formatting, ignoring value" do
    zone = "www 300 IN A 1.1.1.1\nwww.domain.com. A 2.2.2.2\nwww CNAME other\nmail A 3.3.3.3\n"
    c = controller_for(zone)
    matches = c.send(:records_for_owner_type, parse("www A 9.9.9.9"))
    assert_equal ["www 300 IN A 1.1.1.1", "www.domain.com. A 2.2.2.2"], matches
  end

  test "records_for_owner_type returns empty when owner+type absent" do
    c = controller_for("www A 1.1.1.1\nwww CNAME other\n")
    assert_empty c.send(:records_for_owner_type, parse("mail A 9.9.9.9"))
    assert_empty c.send(:records_for_owner_type, parse("www MX 10 mail")), "wrong type does not match"
  end

  # --- controller: zone_with_replaced_record (update's rewrite) ----------------

  test "zone_with_replaced_record swaps the one match and keeps everything else" do
    zone = "; comment\nwww 300 IN A 1.1.1.1\nmail A 3.3.3.3\n"
    c = controller_for(zone)
    result = c.send(:zone_with_replaced_record, parse("www A 9.9.9.9"), "www A 9.9.9.9")
    assert_equal "; comment\nwww A 9.9.9.9\nmail A 3.3.3.3", result
  end

  test "zone_with_replaced_record replaces only the first match" do
    zone = "www A 1.1.1.1\nwww A 2.2.2.2\n"
    c = controller_for(zone)
    result = c.send(:zone_with_replaced_record, parse("www A 9.9.9.9"), "www A 9.9.9.9")
    assert_equal "www A 9.9.9.9\nwww A 2.2.2.2", result
  end
end
