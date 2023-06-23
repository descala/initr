class Initr::BindZone < ActiveRecord::Base

  include IDN

  belongs_to :bind, :class_name => "Initr::Bind"
  has_one :project, :through => :bind
  validates_presence_of :domain, :ttl
  validates_uniqueness_of :domain, :scope => 'bind_id'
  validates_numericality_of :ttl
#  validates_format_of :domain, :with => /\A\w+([\-\.]{1}\w+)*\.[a-z]{2,20}\z/i
  validates_format_of :domain, :with => /\A[^_]+\.[a-z]{2,20}\z/i
  after_save :trigger_puppetrun
  after_destroy :trigger_puppetrun
  before_validation :increment_zone_serial

  # Uses package "apt-get install bind9utils"
  validate :named_checkzone

  after_initialize do
    self.ttl ||= "300"
  end

  def zone
    self[:zone].to_s.gsub(/\r\n?/,"\n")
  end

  def parameters
    {"zone"=>zone,"ttl"=>ttl,"serial"=>serial}
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
    self.active_ns = `dig ns #{domain} +short +time=1 +tries=1 2&>1`.split.sort.join(' ').gsub('. ',' ').gsub(/\.$/,'')
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
    checkzone = "/usr/sbin/named-checkzone"
    if File.exist?(checkzone)
      tmpfile = Tempfile.new([domain,'.conf'])
      tmpfile.write(zone_for_check)
      tmpfile.close
      out = `#{checkzone} #{domain_idn} #{tmpfile.path}`
      if $? != 0
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

  def trigger_puppetrun
    self.bind.trigger_puppetrun
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
