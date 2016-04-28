class Puppet::Rails::SourceFile < ActiveRecord::Base

  begin
    establish_connection("puppet_#{Rails.env}")
  rescue ActiveRecord::AdapterNotSpecified => e
    logger.info "store_configs not configured (#{e.message})"
  end

  has_one :host
  has_one :resource

  def to_label
    "#{self.filename}"
  end

end
