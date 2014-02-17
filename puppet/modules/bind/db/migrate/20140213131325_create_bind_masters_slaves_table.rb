class CreateBindMastersSlavesTable < ActiveRecord::Migration

  def change
    create_table :bind_masters_slaves do |t|
      t.belongs_to :master
      t.belongs_to :slave
    end
  end

end

