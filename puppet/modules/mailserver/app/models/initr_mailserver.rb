class InitrMailserver < Initr::Klass

  unloadable

  REQUIRED_ATTRS = %w(admin_email domain_path domain_in_mailbox mail_location
  webserver db_backend db_name db_user db_passwd db_passwd_encrypt
  db_passwd_encrypt_httpd clamav amavis webmail)
  OPTIONAL_ATTRS = %w(bak_host)


  validate :domain_is_present_on_mailbox_path
  self.accessors_for REQUIRED_ATTRS + OPTIONAL_ATTRS
  validates_presence_of REQUIRED_ATTRS, :on => :update

  after_initialize {
    self.domain_path             ||= '1'
    self.domain_in_mailbox       ||= '0'
    self.mail_location           ||= '/var/mail/virtual'
    self.webserver               ||= 'apache2'
    self.db_backend              ||= 'mysql'
    self.db_name                 ||= 'postfix'
    self.db_user                 ||= 'postfix'
    self.db_passwd_encrypt       ||= 'md5crypt'
    self.db_passwd_encrypt_httpd ||= 'none'
    self.domain_in_mailbox       ||= '1'
    self.domain_path             ||= '0'
    self.clamav                  ||= '1'
    self.amavis                  ||= '1'
    self.webmail                 ||= 'roundcube'
  }

  def domain_is_present_on_mailbox_path
    if domain_path != '1' and domain_in_mailbox != '1'
      errors.add_to_base 'either domain_path or domain_in_mailbox required'
    end
  end

  def name
    'mailserver'
  end

  def description
    'Mail server, with dovecot and postfixadmin'
  end

end
