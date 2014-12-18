# Node hosted at Slicehost
class Initr::Slice < Initr::Node

  unloadable      

  def provider
    if provider_is_configured?
      "Slicehost LLC"
    else
      "Slicehost LLC API not configured"
    end
  end

  def provider_is_configured?
    return Initr::Slice.password.size >= 64
  end

  def provider_partial
    "slicehost"
  end
  
  # proof of concept
  # TODO - it is more efficient to do Slicehost::Slice.find :all
  # every 5 minutes and save the result, it can also send alerts
  def provider_get(attr)
    return if @slice==""
    @slice = Initr::Slicehost::Slice.find(provider_id) unless @slice
    Rails.logger.info "slicehost slice ##{provider_id} = '#{@slice.name}'"
    if @slice.respond_to?(attr)
      return @slice.send(attr)
    else
      "unknown #{attr}"
    end
  rescue
    @slice=""
  end

  def self.site
    "https://#{self.password}@api.slicehost.com/"  
  end

  private
  
  def self.password
    # TODO: create setting in redmine to use this
    # Setting.plugin_initr['slicehost_api_password']
    ""
  end
  
end


module Initr::Slicehost
  class Base < ActiveResource::Base
    self.site = ::Slice.site     
    self.timeout = 2     
  end
  class Address < String; end 
  class Slice  < Base; end 
  class Zone   < Base; end 
  class Record < Base; end
  class Flavor < Base; end
  class Image  < Base; end
  class Backup < Base; end
end
