class Initr::RemoteBackupServer < Initr::Klass

  has_many :remote_backups, :class_name => "Initr::RemoteBackup", :foreign_key => "klass_id"
  validates_presence_of :remotebackups_path, :address, :webreports_url, :on => :update
  self.accessors_for(%w(remotebackups_path address webreports_url))

  after_initialize {
    self.remotebackups_path ||= "/var/backups"
    if node
      self.address            ||= node.fqdn
      self.webreports_url     ||= node.fqdn
    end
  }

  def parameters
    params = super
    params["tags_for_sshkey"] = "#{node.name}_remote_backups_server"
    if address != node.fqdn
      params["host_alias_for_sshkey"] = address
    end
    if Initr::Nagios.for_node(self.node)
      params["remote_backups"] = []
      params["remote_backups_disk_usage_checks"] = {}
      params["remote_backups_reports_users"] = {}
      remote_backups.each do |rb|
        # useful to configure nagios checks:
        params["remote_backups"] << rb.folder
        if rb.used_space_alert.to_i > 0
          params["remote_backups_disk_usage_checks"][rb.node.fqdn] =
            { "threshold" => rb.used_space_alert, "folder" => rb.folder }
        end
        params["remote_backups_reports_users"][rb.node.name[0...8]] =
          { "password" => rb.reportspassword }
      end
    end
    # munin
    begin
      unless Initr::MuninServer.for_node(self.node)
        raise NameError.new # goto rescue code, to not repeat it
      end
    rescue NameError
      params["munin_server_url"] = "munin.#{webreports_url}"
      params["munin_cgi"] = "1"
      params["packages_from_squeeze"] = ["munin"] # http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=585027
    end
    params
  end

  def puppetname
    "remote_backup::server"
  end

end
