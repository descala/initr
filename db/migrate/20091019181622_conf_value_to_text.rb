class ConfValueToText < ActiveRecord::Migration

  def self.up
    change_column(:custom_klass_confs, :value, :text)
  end

  def self.down
    change_column(:custom_klass_confs, :value, :string)
  end

end

