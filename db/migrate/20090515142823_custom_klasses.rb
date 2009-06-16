class CustomKlasses < ActiveRecord::Migration

  def self.up
    rename_column(:confs,:klass_id,:custom_klass_id)
  end

  def self.down
    rename_column(:confs,:custom_klass_id,:klass_id)
  end

end

# you should do in database:
# update klasses set type="CustomKlass" where type is NULL;

