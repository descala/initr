class Initr::Webserver1Domain < ActiveRecord::Base
  unloadable

  require "digest/md5"

  belongs_to :webserver1, :class_name => "Initr::Webserver1"
  belongs_to :web_backups_server, :class_name => "Initr::WebBackupsServer"
  validates_uniqueness_of :name, :scope => :webserver1_id
  validates_uniqueness_of :username, :dbname
  validates_exclusion_of :username, :in => %w( admin ), :message => "Can't use admin username"
  validates_presence_of :name, :username, :password_ftp, :password_db, :password_awstats
  validate :all_dns_fields

  def all_dns_fields
    unless mail_ip.blank? and www_ip.blank? and mx_ip.blank?
      if mail_ip.blank? or www_ip.blank? or mx_ip.blank?
        errors.add_to_base("Must fill all or none DNS fields")
      end
    end
  end

  def parameters
    parameters = { "name"   => name,
                   "username" => username,
                   "password_db" => password_db,
                   "password_awstats" => password_awstats,
                   "password_ftp" => crypted_password,
                   "database" => dbname,
                   "force_www" => force_www.to_s,
                   "web_backups_server" => web_backups_server.nil? ? "" : web_backups_server.address,
                   "web_backups_server_port" => web_backups_server.nil? ? "" : web_backups_server.port }
    parameters["shell"] = "/bin/bash" if self.shell == "1"
    return parameters
  end

  def bind_parameters
    return nil if serial.nil?
    { "serial" =>  serial,
      "wwwip"  => www_ip,
      "mxip"   => mx_ip,
      "mailip" => mail_ip
    }
  end

  def webserver
    webserver1
  end

  def dbname=(db)
    db = self.name.gsub(/[\.-]/,'') if db.blank?
    write_attribute(:dbname,db)
  end

  def save
    if valid?
      # auto-update serial date (YYYYMMDD) + id 001
      if mail_ip_changed? or www_ip_changed? or mx_ip_changed? or name_changed?
        if mail_ip.blank?
          self.serial=nil
        else
          self.serial="#{Time.now.strftime('%Y%m%d')}001".to_i
          unless serial_was.nil?
            while serial <= serial_was
              self.serial += 1
            end
          end
        end
      end
      if password_ftp_changed? or crypted_password.nil? or crypted_password.blank?
        self.crypted_password = password_ftp.crypt("$1$#{random_salt}$")
      end
    end
    super
  end

  def <=>(oth)
    self.name <=> oth.name
  end

  private

  def random_salt
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    salt = ''
    8.times { |i| salt << chars[rand(chars.size-1)] }
    return salt
  end

end
