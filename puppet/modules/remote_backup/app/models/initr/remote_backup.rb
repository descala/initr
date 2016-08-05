class Initr::RemoteBackup < Initr::Klass

  belongs_to :remote_backup_server, :class_name => "Initr::RemoteBackupServer", :foreign_key => "klass_id"
  validates_presence_of :klass_id, :encryptkey, :keypassword, :reportspassword, :on => :update
  validates_numericality_of :num_retries,:bandwidthlimit, :used_space_alert, :only_integer => true, :on => :update

  self.accessors_for(%w(mailto reportsuccess includefiles excludefiles signkey encryptkey keypassword
                        bandwidthlimit used_space_alert reportspassword num_retries archive_dir))
  attr_accessible :klass_id

  after_initialize {
    self.mailto         ||= "root"
    self.reportsuccess  ||= false
    self.includefiles   ||= "/srv/samba"
    self.excludefiles   ||= DEFAULT_EXCLUDE_FILES
    self.bandwidthlimit ||= "0"
    self.num_retries    ||= "5"
    self.archive_dir    ||= "/srv/duplicity"
  }

  def parameters
    unless remote_backup_server
      raise Initr::Klass::ConfigurationError.new("Remote backup class has no remote backups server defined")
    end
    unless remote_backup_server.node
      # should never happen
      raise Initr::Klass::ConfigurationError.new("Selected remote backup server has no node associated")
    end
    params = super
    params["remotebackup"] = self.folder
    params["remotebackups_path"] = remote_backup_server.remotebackups_path
    params["tags_for_sshkey"] = "#{remote_backup_server.node.name}_remote_backups_client"
    params["remote_backup_server_hash"] = remote_backup_server.node.name
    params["remote_backup_server_address"] = remote_backup_server.address
    params
  end

  def folder
    "remotebackup_#{self.node.name[0...8]}"
  end

  def self.remote_backup_servers_for_current_user
    user_projects = User.current.projects
    Initr::RemoteBackupServer.all.collect { |rbs|
      rbs if user_projects.include? rbs.node.project
    }.compact
  end

  DEFAULT_EXCLUDE_FILES = <<EOF
/home/*/.gnupg
/home/*/.local/share/Trash
/home/*/.Trash
/home/*/.thumbnails
/home/*/.beagle
/home/*/.aMule
/home/*/gtk-gnutella-downloads
EOF

  private

  def num_retries_before_type_cast
    num_retries
  end

  def bandwidthlimit_before_type_cast
    bandwidthlimit
  end

  def used_space_alert_before_type_cast
    used_space_alert
  end

end
