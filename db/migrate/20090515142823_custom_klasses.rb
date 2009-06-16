class CustomKlasses < ActiveRecord::Migration

  def self.up
    add_column(:klasses, :name, :string)
    add_column(:klasses, :description, :string)
    Initr::CustomKlass.all.each do |ck|
      ck.name = ck.klass_name.name rescue ""
      ck.description = ck.klass_name.description rescue ""
      ck.save
    end
    remove_column(:klasses, :klass_name_id)
  end

  def self.down
    remove_column(:klasses, :name)
    remove_column(:klasses, :description)
    add_column(:klasses, :klass_name_id, :integer)
  end

end

# you should do in database:
# update klasses set type="CustomKlass" where type is NULL;

