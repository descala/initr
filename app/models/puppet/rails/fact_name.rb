class Puppet::Rails::FactName < ActiveRecord::Base

  begin
    establish_connection("puppet_#{Rails.env}".to_sym)
  rescue ActiveRecord::AdapterNotSpecified => e
    logger.info "store_configs not configured (#{e.message})"
  end

  has_many :fact_values
end
