require 'open3'

class Initr::BindZone < ActiveRecord::Base

  include IDN

  belongs_to :bind, :class_name => "Initr::Bind"
  has_one :project, :through => :bind
  has_many :bind_zone_managers, :class_name => "Initr::BindZoneManager", :dependent => :destroy
  has_many :managers, :through => :bind_zone_managers, :source => :user
  validates_presence_of :domain, :ttl
  validates_uniqueness_of :domain, :scope => 'bind_id'
  validates_numericality_of :ttl
  # Hostname labels of Unicode letters/digits (IDN allowed), hyphen-joined, dot
  # separated, ASCII-letter TLD. Crucially excludes whitespace and shell
  # metacharacters (; $ ( ) ` & | etc.) so a domain can never inject a command.
  validates_format_of :domain, :with => /\A(?:[\p{L}\p{N}](?:[\p{L}\p{N}-]*[\p{L}\p{N}])?\.)+[a-z]{2,20}\z/i
  after_save :trigger_puppetrun
  after_destroy :trigger_puppetrun
  before_validation :increment_zone_serial

  # Master-file control directives a user must never smuggle into the records
  # body. $INCLUDE makes named-checkzone open an arbitrary file on the host and
  # echo fragments of it back through the validation error (authenticated
  # file-read / info disclosure); $GENERATE can explode the zone into millions
  # of records (resource exhaustion). A hosted single-zone records body needs
  # neither. Case-insensitive and whitespace-tolerant because named-checkzone
  # honors $include/$InClUdE; we reject indented forms too (broader than the
  # parser is safe — narrower would be a bypass).
  FORBIDDEN_ZONE_DIRECTIVE = /\A\s*\$(?:INCLUDE|GENERATE)\b/i

  # Must run before named_checkzone so a rejected body never reaches the checker.
  validate :reject_master_file_directives
  # Uses package "apt-get install bind9utils"
  validate :named_checkzone

  after_initialize do
    self.ttl ||= "300"
  end

  def zone
    self[:zone].to_s.gsub(/\r\n?/,"\n")
  end

  # A zone is editable either by one of its assigned managers (holding the
  # global :edit_own_bind_zones permission) or by anyone who may edit klasses
  # in the owning project. Mirrors Initr::Node#editable_by?. Admins always pass.
  def editable_by?(usr)
    (managers.include?(usr) && usr.allowed_to?(:edit_own_bind_zones, nil, :global => true)) ||
      usr.allowed_to?(:edit_klasses, bind&.node&.project)
  end

  def parameters
    {
      zone: zone,
      dnssec: dnssec,
      ttl: ttl,
      serial: serial
    }
  end

  def domain_idn
    Idna.toASCII domain
  end

  def increment_zone_serial
    # auto-update serial date (YYYYMMDD) + id 01
    if domain_changed? or ttl_changed? or zone_changed?
      self.serial="#{Time.now.strftime('%Y%m%d')}01".to_i
      unless serial_was.nil?
        while serial.to_i <= serial_was.to_i
          self.serial = serial.to_i + 1
        end
      end
    end
  end

  def <=>(oth)
    self.domain <=> oth.domain
  end

  def update_active_ns
    # No shell: domain is passed as a discrete argv element, so metacharacters
    # in it can't be interpreted. capture2e merges stderr (the old broken 2&>1).
    out, _status = Open3.capture2e('dig', 'ns', domain, '+short', '+time=1', '+tries=1')
    self.active_ns = out.split.sort.join(' ').gsub('. ',' ').gsub(/\.$/,'')
  end

  def query_registry
    begin
      result = bind.nicline_client.call(
        :info_domain_bbdd,
        message: {
          input: {
            login: Redmine::Configuration['nicline_api_login'],
            password: Redmine::Configuration['nicline_api_password'],
            domain: domain,
            ipOrigen: '0.0.0.0'
          }
        }
      )
      xml = result.hash[:envelope][:body][:info_domain_bbdd_response][:return]
      doc = Nokogiri::Slop xml
      expires_on = doc.response.resData.exDate.content.to_date
      self.expires_on = expires_on
      self.registrant = doc.response.resData.nameRegistrant.content
      self.whois_ns   = doc.response.resData.nameServer.children.collect do |ns|
        ns.children.to_s if ns.children.to_s != ''
      end.compact.sort.join(' ')
      logger.info "nicline: #{expires_on} - #{domain} - #{registrant}"
    rescue => e
      logger.error "error '#{domain}'.query_registry: #{e}"
    end
  end

  def named_checkzone
    return if forbidden_directive_line   # never feed a control directive to the checker
    checkzone = named_checkzone_bin
    if checkzone
      tmpfile = Tempfile.new([domain,'.conf'])
      tmpfile.write(zone_for_check)
      tmpfile.close
      # No shell: each argument is passed discretely to named-checkzone, so a
      # crafted domain can't break out into a command.
      out, status = Open3.capture2e(checkzone, domain_idn, tmpfile.path)
      unless status.success?
        errors.add(:base, "Zone check error: #{out}")
      end
    end
  end

  def www?
    zone =~ /^www[\s\.]/
  end

  def correct_name_servers?
    active_ns == whois_ns
  end

  private

  # The first records line that is a forbidden master-file control directive,
  # or nil. Shared by the validation and by named_checkzone's guard so the two
  # can never drift apart.
  def forbidden_directive_line
    zone.lines.find { |line| line =~ FORBIDDEN_ZONE_DIRECTIVE }
  end

  def reject_master_file_directives
    if forbidden_directive_line
      errors.add(:zone, "must not contain $INCLUDE or $GENERATE control directives")
    end
  end

  def trigger_puppetrun
    self.bind.trigger_puppetrun
  end

  # Locate named-checkzone (bind9-utils). Search PATH plus the usual system
  # dirs — packaging moved it from /usr/sbin to /usr/bin, and the web server's
  # PATH often omits the sbin dirs. Returns nil if it isn't installed.
  def named_checkzone_bin
    dirs = ENV['PATH'].to_s.split(File::PATH_SEPARATOR) | %w[/usr/bin /usr/sbin /bin /sbin]
    dirs.map { |dir| File.join(dir, 'named-checkzone') }.find { |path| File.executable?(path) }
  end

  def zone_for_check
    <<ZONE
$TTL #{ttl}
@   IN  SOA #{bind.nameservers.split.first}.  webmaster.#{domain_idn}. (
            #{serial}
            3600
            600
            604800
            300 )
    IN  NS  #{bind.nameservers.split.first}.
#{zone}
ZONE
  end

end
