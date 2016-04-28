class Puppet::Rails::Host < ActiveRecord::Base

  begin
    establish_connection("puppet_#{Rails.env}")
  rescue ActiveRecord::AdapterNotSpecified => e
    logger.info "store_configs not configured (#{e.message})"
  end

  has_many :resources, :class_name => "Puppet::Rails::Resource"
  has_many :fact_values, :class_name => "Puppet::Rails::FactValue"

  # returns a hash of fact_names.name => [ fact_values ] for this host.
  # Note that 'fact_values' is actually a list of the value instances, not
  # just actual values.
  def get_facts_hash
    fact_values = self.fact_values.find(:all, :include => :fact_name)
    return fact_values.inject({}) do | hash, value |
      hash[value.fact_name.name] ||= []
      hash[value.fact_name.name] << value
      hash
    end
  end

end
