class Puppet::Rails::ResourceTag < ActiveRecord::Base

  begin
    establish_connection("puppet_#{Rails.env}")
  rescue ActiveRecord::AdapterNotSpecified => e
    logger.info "store_configs not configured (#{e.message})"
  end

  belongs_to :puppet_tag
  belongs_to :resource

end
