module Initr
  class WebBackupsServer < Initr::Klass
    unloadable

    def name
      "webserver1::web_backups_server"
    end

    def controller
      "klass"
    end

    def configurable?
      false
    end

    def parameters
      { "webserver1_server_name"=>node.fqdn }
    end

  end
end
