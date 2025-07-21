class CreateBindMastersSlavesTable < ActiveRecord::Migration[5.2]

  def change
    create_table :bind_masters_slaves do |t|
      t.belongs_to :master
      t.belongs_to :slave
    end
  rescue
    nil
  end

end

