class Initr::FtpServer < Initr::Klass

  attr_accessible :ftp_users_attributes

  after_initialize {
    self.config["ftp_writeable"] ||= "0"
    self.config["home_writeable"] ||= "0"
    self.config["extra_users"] ||= ""
  }

  has_many :ftp_users,
    :dependent => :destroy,
    :class_name => "Initr::FtpUser",
    :foreign_key => "klass_id"
  accepts_nested_attributes_for :ftp_users,
    :allow_destroy => true,
    :reject_if => proc {|attributes| attributes['username'].blank? or attributes['password'].blank? }

  def parameters
    p = config
    p["ftp_users"]={}
    self.ftp_users.each do |u|
      p["ftp_users"][u.username]=u.parameters
    end
    p
  end

  self.accessors_for ["ftp_writeable","home_writeable","extra_users"]

end
