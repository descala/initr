class RemoveInitrPrefix < ActiveRecord::Migration

  # run this to remove initr prefix from database objects
  # update klasses set type="Nagios" where type="InitrNagios";
  # update klasses set type="NagiosServer" where type="InitrNagiosServer";

  def self.up
    rename_column :initr_nagios_checks, :initr_nagios_id, :nagios_id
    rename_table :initr_nagios_checks, :nagios_checks
  end

  def self.down
    rename_table :nagios_checks, :initr_nagios_checks
    rename_column :initr_nagios_checks, :nagios_id, :initr_nagios_id
  end

end

