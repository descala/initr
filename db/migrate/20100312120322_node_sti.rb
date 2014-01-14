require_dependency 'initr/node'

class NodeSti < ActiveRecord::Migration

  def self.up
    remove_column :nodes, :type
    add_column :nodes, :type, :string
    Initr::Node.all.each do |n|
      n.type="NodeInstance"
      n.save
    end
  end

  def self.down
    remove_column :nodes, :type
  end

end
