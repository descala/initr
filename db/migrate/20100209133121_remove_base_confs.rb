require_dependency 'initr/base'

class RemoveBaseConfs < ActiveRecord::Migration

  def self.up
    drop_table :base_confs
    Initr::Base.all.collect {|b|
      b.config=OpenStruct.new(["puppet"])
      b.config.puppet="none"
      b.save
    }
  end

  def self.down
    create_table :base_confs do |t|
      t.integer :base_id
      t.string :optshash
      t.timestamps
    end
    Initr::Base.all.collect {|b|
      b.config={}
      b.save
    }
  end

end
