class Puppet::Rails::ParamValue < ActiveRecord::Base

  begin
    establish_connection("puppet_#{Rails.env}".to_sym)
  rescue ActiveRecord::AdapterNotSpecified => e
    logger.info "store_configs not configured (#{e.message})"
  end

  belongs_to :param_name
  belongs_to :resource

end
