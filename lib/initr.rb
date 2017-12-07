require_dependency 'puppetdb'

module Initr
  class <<self
    # If https://github.com/descala/haltr is installed
    def haltr?
      Redmine::Plugin.installed? 'haltr'
    end

    def puppetdb
      PuppetDB::Client.new({:server => 'http://172.18.0.2:8080'})
    end
  end
end
