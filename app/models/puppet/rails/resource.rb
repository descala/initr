class Puppet::Rails::Resource < ActiveRecord::Base

  begin
    establish_connection("puppet_#{Rails.env}".to_sym)
  rescue ActiveRecord::AdapterNotSpecified => e
    logger.info "store_configs not configured (#{e.message})"
  end

  belongs_to :host
  belongs_to :source_file
  has_many :param_values, :class_name => "Puppet::Rails::ParamValue"
  has_many :puppet_tags, :through => :resource_tags, :class_name => "Puppet::Rails::PuppetTag"
  has_many :resource_tags, :class_name => "Puppet::Rails::ResourceTag"

  def name
    ref
  end

  def ref(dummy_argument=:work_arround_for_ruby_GC_bug)
    "#{self[:restype].split("::").collect { |s| s.capitalize }.join("::")}[#{self.title}]"
  end

end
