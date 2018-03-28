class Initr::FtpUser < Initr::Klass

  attr_protected #none

  belongs_to :ftp_server, :class_name => "Initr::FtpServer", :foreign_key => "klass_id"

  after_initialize {
    self.config ||= {}
  }

  # Allow more than one FtpUser per node
  # see validates_uniqueness_of on Klass
  def unique?; false end

  def parameters
    { "password" => cryptedpassword }
  end

  def username
    self.config ||= {}
    self.config["username"]
  end
  def username=(n)
    self.config ||= {}
    self.config["username"]=n
  end
  def password
    self.config ||= {}
    self.config["password"]
  end
  def password=(p)
    self.config ||= {}
    oldp = config["password"]
    self.config["password"]=p
    self.cryptedpassword = p.crypt("$1$#{random_salt}$") if oldp != p
    #TODO: without this save, passwords can't be updated (why?)
    save if oldp != p
  end
  def cryptedpassword
    self.config ||= {}
    self.config["cryptedpassword"]
  end
  def cryptedpassword=(p)
    self.config ||= {}
    self.config["cryptedpassword"]=p
  end

  private

  def random_salt
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    salt = ''
    8.times { |i| salt << chars[rand(chars.size-1)] }
    return salt
  end
end

