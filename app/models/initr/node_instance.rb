class Initr::NodeInstance < Initr::Node
  validates_uniqueness_of :name
  validates_presence_of :project

  after_save :trigger_puppetrun
  after_create :add_base_klass

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

  def facts
    return @facts if @facts
    data = Initr.puppetdb.request('',"facts[name,value] {certname = '#{name}'}").data rescue {}
    if data.empty? and puppet_host
      @facts = puppet_host.get_facts_hash
    else
      # [
      #  {"name"=>"kernel", "value"=>"Linux"},
      #  {"name"=>"kernelrelease", "value"=>"4.9.0-4-amd64"}
      # ]
      hash = {}
      data.each do |fact|
        hash[fact['name']] = fact['value'] rescue nil
      end
      @facts = hash
    end
  end

  def fact(factname, default=nil)
    if @facts
      # we have previously loaded all facts
      if facts.has_key? factname
        facts[factname]
      else
        default
      end
    else
      # facts not loaded, we are just interested in one fact
      data = Initr.puppetdb.request('',"facts[name,value] {certname = '#{name}' and name = '#{factname}'}").data rescue {}
      if data.empty? and puppet_host
        if fv = puppet_host.fact_values.includes(:fact_name).references(:fact_name).where("fact_names.name = '#{factname}'")
          fv.first.value
        else
          nil
        end
      else
        data.first['value'] rescue default
      end
    end
  rescue
    default
  end

  def exported_resources
    return @exported_resources if @exported_resources
    data = Initr.puppetdb.request('',"resources {certname = '#{name}' and exported = true }").data rescue {}
    if data.empty? and puppet_host
      # try with ActiveRecord instead of PuppetDB
      @exported_resources = puppet_host.get_exported_resources_hash
    else
      hash = {}
      data.each do |res|
        hash["#{res['type']}[#{res['title']}]"] = res['parameters'] rescue nil
      end
      @exported_resources = hash
    end
  end

  # TODO we should do here the equivalent to this in the puppetmaster:
  #      puppet node deactivate #{certname}
  def destroy_exported_resources
    exported_resources.each do |r|
      r.destroy
    end
  end

  def puppetversion
    fact('puppetversion','?')
  end

  def os
    f = fact('lsbdistid')
    f = fact('operatingsystem') unless f
    logger.debug("OS= '#{f}'") if logger
    return f
  end

  def os_release
    f = fact('lsbdistrelease')
    f = fact('operatingsystemrelease','?') unless f
    return f
  end

  def hostname
    fact("hostname",name)
  end

  # if there is no domain fact, we define domain as
  # removing the hostname part of the fqdn
  def domain
    d = fact 'domain'
    d = fqdn.gsub("#{hostname}.",'') if d.nil?
    d
  end

  def fqdn
    fact("fqdn", hostname)
  end

  def reverse_fqdn
    self.fqdn.split(".").reverse.join("_")
  end

  def ip
    fact('ipaddress')
  end

  def kernel
    begin
      a = fact('kernelrelease').split(/\.|-|mdk/)
        "#{a[0]}.#{a[1]}.#{a[2]}-#{a[3]}"
    rescue Exception
      ''
    end
  end

  def config_errors?
    self.parameters["classes"].include? "common::configuration_errors"
  end

  def config_errors
    self.parameters["classes"]["common::configuration_errors"]["errors"] rescue []
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
