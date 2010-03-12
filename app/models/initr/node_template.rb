class Initr::NodeTemplate < Initr::Node
  unloadable
  validates_uniqueness_of :name, :scope => :project_id
end
