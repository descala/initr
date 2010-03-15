class Initr::NodeTemplate < Initr::Node
  unloadable
  validates_uniqueness_of :name, :scope => :user_id

  def project
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
