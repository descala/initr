class Initr::BindZone < ActiveRecord::Base
  unloadable
  belongs_to :bind, :class_name => "Initr::Bind"
  validates_presence_of :domain, :ttl
  validates_uniqueness_of :domain, :scope => 'bind_id'
  validates_numericality_of :ttl
  validates_format_of :domain, :with => /^[\w\d]+([\-\.]{1}[\w\d]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/i
  validates_format_of :domain, :with => /^[^_]+$/i

  def initialize(attributes=nil)
    super
    self.ttl ||= "300"
  end

  def parameters
    {"zone"=>zone,"ttl"=>ttl,"serial"=>serial}
  end

  def save
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
    super
  end

  def <=>(oth)
    self.domain <=> oth.domain
  end

end
