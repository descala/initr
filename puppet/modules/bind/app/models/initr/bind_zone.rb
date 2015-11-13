class Initr::BindZone < ActiveRecord::Base
  unloadable
  belongs_to :bind, :class_name => "Initr::Bind"
  has_one :project, :through => :bind
  validates_presence_of :domain, :ttl
  validates_uniqueness_of :domain, :scope => 'bind_id'
  validates_numericality_of :ttl
  validates_format_of :domain, :with => /^[\w\d]+([\-\.]{1}[\w\d]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/i
  validates_format_of :domain, :with => /^[^_]+$/i
  after_save :trigger_puppetrun
  after_destroy :trigger_puppetrun
  before_save :increment_zone_serial

  if Initr.haltr?
    belongs_to :invoice_line
    has_one :invoice, :through => :invoice_line

    def template_lines
      like = "%#{domain}%"
      project.invoice_lines.where("invoices.type = 'InvoiceTemplate' and invoice_lines.description like ? or invoice_lines.notes like ?",like,like)
    end
  end

  after_initialize do
    self.ttl ||= "300"

    # Search a matching invoice_line in haltr templates
    # only if not already set
    if Initr.haltr? and project and !invoice_line
      self.invoice_line = template_lines.first
    end
  end

  def parameters
    {"zone"=>zone,"ttl"=>ttl,"serial"=>serial}
  end

  def increment_zone_serial
    if valid?
      # auto-update serial date (YYYYMMDD) + id 01
      if domain_changed? or ttl_changed? or zone_changed?
        self.serial="#{Time.now.strftime('%Y%m%d')}01".to_i
        unless serial_was.nil?
          while serial <= serial_was.to_i
            self.serial += 1
          end
        end
      end
    end
  end

  def <=>(oth)
    self.domain <=> oth.domain
  end

  def whois
    return @whois if @whois
    @whois = Whois.whois(domain)
  end

  def update_active_ns
    self.active_ns = `dig ns #{domain} +short +time=1 +tries=1 2&>1`.split.sort.join(' ')
  end

  private

  def trigger_puppetrun
    self.bind.trigger_puppetrun
  end

end
