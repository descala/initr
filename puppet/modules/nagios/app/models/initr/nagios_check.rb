class Initr::NagiosCheck < ActiveRecord::Base

  unloadable

  belongs_to :nagios, :class_name => "Initr::Nagios"
  validates_presence_of :name, :command
  after_initialize :set_default_values

  def validate
    # name can't contain single quotes
    errors.add(:name, "can't have single quotes") if name =~ /'/
    # name can't be repeated on the same node, but we must check for a recently
    # deleted check with the same name, that is not yet destroyed by delete_check_job
    existing = Initr::NagiosCheck.find :all,
      :conditions => ["nagios_id=? and (name=? or command=?)",self.nagios_id, self.name, self.command]
    existing.each do |e|
      if e.ensure == "absent"
        e.destroy
      end
      unless self == e
        errors.add(:name, "already taken") if e.name == self.name
        errors.add(:command, "already taken") if e.command == self.command
      end
    end
  end

  def puppetconf
    check = {}
    check["ensure"]          = self.ensure unless self.ensure.nil? or self.ensure.blank?
    check["name"]            = self.name unless self.name.nil? or self.name.blank?
    check["command"]         = self.command unless self.command.nil? or self.command.blank?
    check["checkfreshness"]  = self.check_freshness ? "1" : "0"
    check["freshness"]       = self.freshness unless self.freshness.nil? or self.freshness.blank?
    check["minute"]          = self.minute unless self.minute.nil? or self.minute.blank?
    check["hour"]            = self.hour unless self.hour.nil? or self.hour.blank? or self.hour == "*"
    check["notifications_enabled"] = self.notifications_enabled ? "1" : "0"
    # puppet has been notified to delete this check,
    # destroy it, but wait 2 days for nagios server being notified
    if self.ensure == "absent" and self.updated_at < ( Time.now - 2.day )
      self.destroy
    end
    return check
  end

  def set_default_values
    if new_record?
      # set default values for new records only
      self.ensure                ||= "present"
      self.freshness             ||= "950"
      self.minute                ||= "*/5"
      self.hour                  ||= "*"
      self.check_freshness=true if self.check_freshness.nil?
      self.notifications_enabled=true if self.notifications_enabled.nil?
    end
  end

  def <=>(oth)
    self.name.downcase <=> oth.name.downcase
  end

end

