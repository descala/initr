# Parses a single zone-file line into a canonical (owner, type, rdata) triple
# so records compare by *meaning* rather than text. All of these parse to the
# same record for zone "domain.com":
#
#   @            A   1.2.3.4
#   domain.com.  A   1.2.3.4
#   @  3600  IN  A   1.2.3.4
#
# Only owner, type and rdata identify a record; TTL and class are ignored.
# rdata is normalised per type: names inside CNAME/NS/PTR/DNAME, the MX
# exchange and the SRV target are expanded to absolute names, while TXT
# character-strings are unquoted and concatenated (DNS joins them with no
# separator, so spacing inside the quotes stays significant).
class Initr::DnsRecord
  CLASSES    = %w[IN CH HS CS HESIOD].freeze
  NAME_TYPES = %w[CNAME NS PTR DNAME].freeze        # rdata is a single name
  TYPES      = (NAME_TYPES + %w[A AAAA MX TXT SPF SRV TLSA CAA NAPTR DS SSHFP SOA]).freeze

  attr_reader :owner, :type, :rdata

  # Returns a DnsRecord, or nil for a blank/comment line or an unrecognised
  # type. +origin+ is the zone domain; +inherited_owner+ is the owner carried
  # over for indented (continuation) lines.
  def self.parse(line, origin:, inherited_owner: '@')
    body = strip_comment(line.to_s)
    return nil if body.strip.empty?

    indented = body =~ /\A[ \t]/
    tokens   = tokenize(body)
    owner_token = indented ? inherited_owner : tokens.shift
    return nil if owner_token.nil?

    tokens.shift while tokens.first && ttl_or_class?(tokens.first)

    type = tokens.shift
    return nil unless type && TYPES.include?(type.upcase)

    new(normalize_name(owner_token, origin),
        type.upcase,
        normalize_rdata(type.upcase, tokens, origin))
  end

  def initialize(owner, type, rdata)
    @owner = owner
    @type  = type
    @rdata = rdata
  end

  def ==(other)
    other.is_a?(Initr::DnsRecord) &&
      owner == other.owner && type == other.type && rdata == other.rdata
  end
  alias eql? ==

  def hash
    [owner, type, rdata].hash
  end

  # True when +other+ shares this record's owner and type — the "key" the
  # update-by-key action matches on (rdata and TTL are ignored).
  def same_key?(other)
    other.is_a?(Initr::DnsRecord) && owner == other.owner && type == other.type
  end

  # Cut at the first ';' that is not inside a quoted string, so semicolons in
  # TXT values (DKIM/DMARC/SPF) are not treated as comments.
  def self.strip_comment(str)
    out = +''
    in_quote = false
    escaped  = false
    str.each_char do |ch|
      if escaped
        out << ch
        escaped = false
      elsif ch == '\\'
        out << ch
        escaped = true
      elsif ch == '"'
        in_quote = !in_quote
        out << ch
      elsif ch == ';' && !in_quote
        break
      else
        out << ch
      end
    end
    out
  end

  # Whitespace-delimited tokens, keeping quoted strings whole.
  def self.tokenize(str)
    str.scan(/"(?:\\.|[^"\\])*"|\S+/)
  end

  def self.ttl_or_class?(token)
    token =~ /\A\d+[smhdwSMHDW]?\z/ || CLASSES.include?(token.upcase)
  end

  # Expand a name to absolute, lower-cased, no trailing dot:
  #   "@" -> origin ; "www" -> "www.origin" ; "www.foo.com." -> "www.foo.com"
  def self.normalize_name(name, origin)
    base = origin.to_s.downcase.chomp('.')
    return base if name == '@'
    n = name.downcase
    n.end_with?('.') ? n.chomp('.') : "#{n}.#{base}"
  end

  def self.normalize_rdata(type, tokens, origin)
    case type
    when *NAME_TYPES
      normalize_name(tokens.first.to_s, origin)
    when 'MX'
      pref, exchange = tokens
      "#{pref.to_i} #{normalize_name(exchange.to_s, origin)}"
    when 'SRV'
      prio, weight, port, target = tokens
      "#{prio.to_i} #{weight.to_i} #{port.to_i} #{normalize_name(target.to_s, origin)}"
    when 'TXT', 'SPF'
      # concatenate character-strings with no separator (DNS semantics); case
      # is significant for TXT, so do not downcase
      tokens.map { |t| unquote(t) }.join
    when 'AAAA'
      tokens.join(' ').downcase
    else
      # A and anything else: collapse whitespace, lower-case
      tokens.join(' ').downcase
    end
  end

  def self.unquote(token)
    if token.length >= 2 && token.start_with?('"') && token.end_with?('"')
      token[1..-2].gsub(/\\(.)/, '\1')
    else
      token
    end
  end
end
