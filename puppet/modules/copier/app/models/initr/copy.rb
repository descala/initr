class Initr::Copy < ActiveRecord::Base
  belongs_to :copier, :class_name => "Initr::Copier"
  validates_presence_of :name, :source, :destination, :bdays, :fs
  validates_uniqueness_of :name, :scope => :copier_id
  validates_numericality_of :bdays, :only_integer => true
  validates_inclusion_of :fs, :in => %w( ext3 ntfs fat32 curlftpfs rsyncd rdiff-backup )
  validates_inclusion_of :mount_type, :in => %w( usb ), :allow_blank => true
  validates_numericality_of :warn

  after_initialize {
    self.source          ||= "/var/arxiver"
    self.destination     ||= "/auto/backups/incremental"
    self.historic        ||= "/auto/backups"
    self.bdays           ||= "7"
    self.fs              ||= "fat32"
    self.excludes        ||= "/lost+found/"
    self.options         ||= ""
    self.mount_type      ||= "usb"
    self.mount_file_to_check ||= ""
    self.name            ||= "backup_local"
    self.minute          ||= "0"
    self.hour            ||= "3"
    self.weekday         ||= "*"
    self.monthday        ||= "*"
    self.warn            ||= "24"
    self.rsyncd_password ||= ""
    self.email           ||= ""
  }

  def excludes
    self[:excludes].to_s.gsub(/\r\n?/,"\n")
  end

  def parameters
    {
      "name" => self.name,
      "source" => self.source,
      "destination" => self.destination,
      "historic" => self.historic,
      "bdays" => self.bdays,
      "fs" => self.fs,
      "excludes" => self.excludes,
      "options" => self.options,
      "mount_type" => self.mount_type,
      "mount_file_to_check" => self.mount_file_to_check,
      "hour" => for_cron(self.hour),
      "minute" => for_cron(self.minute),
      "weekday" => for_cron(self.weekday),
      "monthday" => for_cron(self.monthday),
      "warn" => (self.warn * 3600),
      "rsyncd_password" => self.rsyncd_password,
      "email" => email
    }
  end

  private

  def for_cron(v)
    v =~ /,/ ? v.split(",") : v
  end
end
