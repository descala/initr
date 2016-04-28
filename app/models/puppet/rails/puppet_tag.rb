class Puppet::Rails::PuppetTag < ActiveRecord::Base

  begin
    establish_connection("puppet_#{Rails.env}")
  rescue ActiveRecord::AdapterNotSpecified => e
    logger.info "store_configs not configured (#{e.message})"
  end

  has_many :resources, :through => :resource_tags

end
