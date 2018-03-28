class InitrMailserver2 < Initr::Klass

  validate :domain_is_present_on_mailbox_path
  validates_presence_of :mailserver2_admin_email, :on => :update
  self.accessors_for %w( mailserver2_admin_email domain_path domain_in_mailbox mailserver2_mail_location )

  after_initialize {
    self.domain_path               ||= "1"
    self.domain_in_mailbox         ||= "0"
    self.mailserver2_mail_location ||= "/var/mail/virtual"
  }

  def domain_is_present_on_mailbox_path
    if domain_path != "1" and domain_in_mailbox != "1"
      errors.add_to_base "either domain_path or domain_in_mailbox required"
    end
  end

  def name
    "mailserver2"
  end

  def description
    "Mail server, with dovecot and postfixadmin"
  end
  
end
