class Initr::NodeTemplate < Initr::Node
  unloadable
  validates_uniqueness_of :name, :scope => :user_id

  def visible_by?(usr)
    (usr == user && usr.allowed_to?(:view_own_nodes, project, :global=>true)) || usr.allowed_to?(:view_nodes, project)
  end

  def project
    return Project.find(project_id) if Project.exists?(project_id)
    Initr::FakeProject.new
  end

  def puppet_host
  end

  def fqdn
    name
  end

  def config_errors?
    false
  end

  def puppet_fact(factname, default=nil)
    "&lt;#{factname}&gt;"
  end

end
