class Initr::FakeProject < Project
  unloadable

  def id
    nil
  end

  def name
    "no project"
  end

  def allows_to?(action)
    true
  end

end
