class Initr::RemoteBackupServer < Initr::Klass
  unloadable

  has_many :remote_backups, :class_name => "Initr::RemoteBackup", :foreign_key => "klass_id"
  validates_presence_of :remotebackups_path, :on => :update
  self.accessors_for(%w(remotebackups_path address))

  def initialize(attributes=nil)
    super
    self.remotebackups_path ||= "/var/backups"
    self.address ||= node.fqdn
  end

  def parameters
    params = super
    params["tags_for_sshkey"] = "#{node.name}_remote_backups_server"
    if address != node.fqdn
      params["host_alias_for_sshkey"] = address
    end
    params
  end

  def puppetname
    "remote_backup::server"
  end

end
