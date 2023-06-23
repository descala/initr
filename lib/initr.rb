require_dependency 'puppetdb'

module Initr
  class <<self
    def puppetdb
      PuppetDB::Client.new({:server => 'http://puppet:8080'})
    end
  end
end
