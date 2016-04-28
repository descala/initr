class Puppet::Rails::FactValue < ActiveRecord::Base

  begin
    establish_connection("puppet_#{Rails.env}")
  rescue ActiveRecord::AdapterNotSpecified => e
    logger.info "store_configs not configured (#{e.message})"
  end

  belongs_to :fact_name
  belongs_to :host

  def to_label
    "#{self.fact_name.name}"
  end

end
