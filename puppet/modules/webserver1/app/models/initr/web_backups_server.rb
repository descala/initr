module Initr
  class WebBackupsServer < Initr::Klass
    unloadable

    validate :address_is_unique

    def address_is_unique
      if new_record?
        if WebBackupsServer.all.collect {|wbs| wbs.address}.include? address
          errors.add_to_base("#{l "address"} has already been taken")
        end
      else
        if WebBackupsServer.all.collect {|wbs| wbs.address if wbs.id != self.id }.include? address
          errors.add_to_base("#{l "address"} has already been taken")
        end
      end
    end

    def initialize(attributes=nil)
      super
      port ||= "22"
      address ||= ""
      #backups_path ||= "/var/backups"
    end

    def name
      "webserver1::web_backups_server"
    end

    def parameters
      { "webserver1_server_name"=>node.fqdn,
        "tags_for_sshkey"=>"#{address}_backup" }
    end

    def address
      config["address"]
    end
    def address=(a)
      config["address"]=a
    end

    def port
      config["port"]
    end
    def port=(p)
      config["port"]=p
    end

    #TODO
#    def backups_path
#      config["backups_path"]
#    end
#    def backups_path=(p)
#      config["backups_path"]=p
#    end

  end
end
