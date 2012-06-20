module Initr
  class WebBackupsServer < Initr::Klass
    unloadable

    has_many :webserver1_domains, :class_name => "Initr::Webserver1Domain"
    validate :address_is_unique, :on => :update
    validates_presence_of :backups_path, :port, :address, :on => :update

    def address_is_unique
      if WebBackupsServer.all(:conditions=>["id != ?",id]).collect {|wbs| wbs.address }.include? address
        errors.add_to_base("#{l "address"} has already been taken")
      end
    end

    def initialize(attributes=nil)
      super
      port ||= "22"
      address ||= ""
      backups_path ||= "/var/backups"
    end

    def name
      "webserver1::web_backups_server"
    end

    def parameters
      params = { "tags_for_sshkey" => "#{address}_web_backups_server",
                 "backups_path" => backups_path,
                 "address" => address }
      if address != node.fqdn
        params["host_alias_for_sshkey"] = address
      end
      params
    end

    def address
      return node.fqdn if config["address"] == "" or config["address"].nil?
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

    def backups_path
      config["backups_path"]
    end
    def backups_path=(p)
      config["backups_path"]=p
    end

  end
end
