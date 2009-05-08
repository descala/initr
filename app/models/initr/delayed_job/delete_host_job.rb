#
# Delayed job responsible of:
#
# - Delete nodes without puppethost and remove them
#   from /etc/puppet/autosign file
#   this job is stored with a run_at timestamp in the
#   future, see Initr::Node after_save method.
#
#TODO: job doesn't works:
# Mysql::Error: MySQL server has gone away: SELECT * FROM `hosts` WHERE (`hosts`.`name` = 'xxx')  LIMIT 1
# seems because puppet::hosts uses other database

class Initr::DelayedJob::DeleteHostJob < Struct.new(:id)

  def perform
    n=Initr::Node.find id
    return unless n.puppet_host.nil?
    path=Setting.plugin_initr_plugin['autosign']
    `/bin/grep -v "^#{n.fqdn}$" #{path} > /tmp/autosign_`
    `/bin/mv /tmp/autosign_ #{path}`
    `chmod 644 #{path}`
    `chown apache: #{path}`
    n.destroy
  rescue ActiveRecord::RecordNotFound => e
    return
  end

end
