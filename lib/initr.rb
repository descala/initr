require_dependency 'puppetdb'

module Initr
  class <<self
    # If https://github.com/descala/haltr is installed
    def haltr?
      Redmine::Plugin.installed? 'haltr'
    end

    def puppetdb
      PuppetDB::Client.new({:server => 'http://puppet:8080'})
    end
  end
end
