class Initr::NodeTemplate < Initr::Node
  validates_uniqueness_of :name, :scope => :user_id

  def project
    return Project.find(project_id) if Project.exists?(project_id)
    Initr::FakeProject.new
  end

  def fqdn
    name
  end

  def config_errors?
    false
  end

  def fact(factname, default=nil)
    "&lt;#{factname}&gt;"
  end

end
