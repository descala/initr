module Initr
  class <<self
    # If https://github.com/descala/haltr is installed
    def haltr?
      Redmine::Plugin.installed? 'haltr'
    end
  end
end
