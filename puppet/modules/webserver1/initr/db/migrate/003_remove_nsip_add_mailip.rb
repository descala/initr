class RemoveNsipAddMailip < ActiveRecord::Migration

  def self.up
    rename_column :initr_webserver1_domains, :ns_ip, :mail_ip
  end

  def self.down
    rename_column :initr_webserver1_domains, :mail_ip, :ns_ip
  end

end

