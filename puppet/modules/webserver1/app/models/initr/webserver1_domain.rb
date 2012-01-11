class Initr::Webserver1Domain < ActiveRecord::Base
  unloadable

  require "digest/md5"

  belongs_to :webserver1, :class_name => "Initr::Webserver1"
  belongs_to :web_backups_server, :class_name => "Initr::WebBackupsServer"
  validates_uniqueness_of :name, :scope => :webserver1_id
  validates_uniqueness_of :name, :scope => :web_backups_server_id
  validates_format_of :name, :with => /^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/i
  validates_uniqueness_of :dbname, :scope => :webserver1_id, :unless => Proc.new {|domain| domain.dbname.nil? or domain.dbname.blank?}
  validates_uniqueness_of :user_ftp,     :scope => :webserver1_id
  validates_uniqueness_of :user_awstats, :scope => :webserver1_id
  validates_uniqueness_of :user_mysql,   :scope => :webserver1_id
  validates_exclusion_of :user_ftp, :user_awstats, :user_mysql, :in => %w( admin root ), :message => "Can't use admin/root username"
  validates_presence_of :name, :user_ftp, :user_awstats, :user_mysql, :password_ftp, :password_awstats
  validates_presence_of :password_db, :unless => Proc.new {|domain| domain.dbname.nil? or domain.dbname.blank?}
  validates_length_of :user_ftp, :in => 1..16

  def initialize(attributes=nil)
    super
    self.add_www = true if self.add_www.nil?
    self.force_www = true if self.force_www.nil?
    self.awstats_www = false if self.awstats_www.nil?
  end

  def parameters
    parameters = { "name" => name,
                   "user_ftp" => user_ftp,
                   "user_awstats" => user_awstats,
                   "user_mysql" => user_mysql,
                   "password_db" => password_db,
                   "password_awstats" => password_awstats,
                   "password_ftp" => crypted_password,
                   "database" => dbname,
                   "add_www" => add_www.to_s,
                   "force_www" => force_www.to_s,
                   "awstats_www" => awstats_www.to_s,
                   "use_suphp" => use_suphp.to_s }
    if web_backups_server
      parameters["web_backups_server"] = web_backups_server.address
      parameters["web_backups_server_port"] = web_backups_server.port
      parameters["backups_path"] = web_backups_server.backups_path unless web_backups_server.backups_path.nil? or web_backups_server.backups_path.blank?
    end
    if railsapp
      parameters["railsapp"] = "true"
      parameters["rails_root"] = rails_root
      parameters["rails_spawn_method"] = rails_spawn_method
    else
      parameters["railsapp"] = "false"
    end
    parameters["shell"] = "/bin/bash" if self.shell == "1"
    return parameters
  end

  def webserver
    webserver1
  end

  def before_validation
    if password_ftp_changed? or crypted_password.nil? or crypted_password.blank?
      self.crypted_password = password_ftp.crypt("$1$#{random_salt}$")
    end
  end

  def <=>(oth)
    self.name <=> oth.name
  end

  def name=(fqdn)
    fqdn.gsub!(/^ */,'')
    fqdn.gsub!(/ *$/,'')
    write_attribute(:name,fqdn)
  end

  private

  def random_salt
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    salt = ''
    8.times { |i| salt << chars[rand(chars.size-1)] }
    return salt
  end

end
