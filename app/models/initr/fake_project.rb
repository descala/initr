class Initr::FakeProject < Project
  unloadable

  def allows_to?(action)
    true
  end

end
