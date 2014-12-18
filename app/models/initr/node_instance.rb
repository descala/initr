require 'puppet/rails/host'

class Initr::NodeInstance < Initr::Node
  unloadable
  validates_uniqueness_of :name
  validates_presence_of :project

  after_save :trigger_puppetrun
  after_create :add_base_klass
  after_destroy :puppet_host_destroy

  #TODO
#  def validate
#    unless user.member_of?(project) or user.admin?
#      errors.add_to_base "User #{user.name} don't belongs to #{project.name} project."
#    end
#  end

  def add_base_klass
    b = Initr::Base.new
    self.klasses << b
  end

  def self.find(*args)
    if args.first && args.first.is_a?(String) && !args.first.match(/^\d*$/)
      node = find_by_name(*args)
      raise ActiveRecord::RecordNotFound, "Couldn't find Node with name=#{args.first}" if node.nil?
      node
    else
      super
    end
  end

  def provider
    "User provided"
  end

  def provider_is_configured?
    true
  end

  def provider_partial
    "no_provider"
  end

  # returns the host of the puppethost of this node
  def puppet_host
    return @host_object if @host_object
    @host_object = Puppet::Rails::Host.find_by_name(name)
    logger.debug("Puppet::Rails::Host for '#{name}' is a class='#{@host_object.class}'") if logger
    return @host_object
  end

  def puppet_host_destroy
    @host_object = puppet_host
    Puppet::Rails::Host.destroy @host_object if @host_object
  end

  def exported_resources
    puppet_host.resources.find :all,:conditions => ['exported',true], :order => "restype, title"
  end

  def destroy_exported_resources
    exported_resources.each do |r|
      r.destroy
    end
  end

  def puppet_fact(factname, default=nil)
    begin
      if fv = puppet_host.fact_values.find(
        :all, :include => :fact_name,
        :conditions => "fact_names.name = '#{factname}'")
        return fv.first.value
      else
        return nil
      end
    rescue
      default
    end
  end

  def puppet_attribute(attribute, default=nil)
    begin
      puppet_host.send(attribute)
    rescue
      default
    end
  end

  def puppetversion
    puppet_fact('puppetversion','?')
  end

  def os
    f = puppet_fact('lsbdistid')
    f = puppet_fact('operatingsystem') unless f
    logger.debug("OS= '#{f}'") if logger
    return f
  end

  def os_release
    f = puppet_fact('lsbdistrelease')
    f = puppet_fact('operatingsystemrelease','?') unless f
    return f
  end

  def hostname
    puppet_fact("hostname",name)
  end

  # if there is no domain fact, we define domain as
  # removing the hostname part of the fqdn
  def domain
    d = puppet_fact 'domain'
    d = fqdn.gsub("#{hostname}.",'') if d.nil?
    d
  end

  def fqdn
    puppet_fact("fqdn", hostname)
  end

  def reverse_fqdn
    self.fqdn.split(".").reverse.join("_")
  end

  def ip
    puppet_attribute('ipaddress')
  end

  def compile_warning?
    begin
      (Time.now - puppet_attribute('last_compile')) > 60 * 30
    rescue
      false
    end
  end

  def compile
    begin
      remaining(puppet_attribute('last_compile'))
    rescue Exception
      ''
    end

  end

  def kernel
    begin
      a = puppet_fact('kernelrelease').split(/\.|-|mdk/)
        "#{a[0]}.#{a[1]}.#{a[2]}-#{a[3]}"
    rescue Exception
      ''
    end
  end

  def config_errors?
    self.parameters["classes"].include? "common::configuration_errors"
  end

  def config_errors
    self.parameters["classes"]["common::configuration_errors"]["errors"]
  end

  def report
    # TODO redmine2 - reports fail
    # self.reports.sort.last
  end

  # shamelessly taken from Foreman project (http://theforeman.org)
  def status(type = nil)
    raise "invalid type #{type}" if type and not Initr::Report::METRIC.include?(type)
    h = {}
    (type || Initr::Report::METRIC).each do |m|
      h[m] = (read_attribute(:puppet_status) || 0) >> (Initr::Report::BIT_NUM*Initr::Report::METRIC.index(m)) & Initr::Report::MAX
    end
    return type.nil? ? h : h[type]
  end

  def <=>(other)
    self.fqdn.downcase <=> other.fqdn.downcase
  end

  def valid_fqdn?
    # http://en.wikipedia.org/wiki/Hostname#Restrictions_on_valid_host_names
    f=fqdn
    return false unless f
    return false unless f.size <= 255
    f.split('.').each do |label|
      return false unless (1..64) === label.size
    end
    return false unless f.downcase =~ /^[a-z0-9][a-z0-9.-]+[a-z0-9]$/
    true
  end

  private

  def trigger_puppetrun
    # uncomment on rails 3, rails 2.3.5 does not detect changes on serialized columns
    # https://rails.lighthouseapp.com/projects/8994/tickets/360-dirty-tracking-on-serialized-columns-is-broken
    # return unless self.changed?
	return if self.last_report_changed? # avoid triggering puppetruns on report saves
    begin
      open("public/puppetrun_#{self.name}",'w') {|f| f << Time.now.to_i }
    rescue
    end
  end

end
