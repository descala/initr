require 'puppet/rails/host'
require 'user'
require 'date'

class Initr::Node < ActiveRecord::Base

  unloadable

  has_many :klasses, :dependent => :destroy, :class_name => "Initr::Klass"
  belongs_to :project

  validates_presence_of :name
  validates_uniqueness_of :name
  
  def self.find(*args)
    if args.first && args.first.is_a?(String) && !args.first.match(/^\d*$/)
      node = find_by_name(*args)
      raise ActiveRecord::RecordNotFound, "Couldn't find Node with name=#{args.first}" if node.nil?
      node
    else
      super
    end
  end

  def parameters
    # node parameters
    parameters = { }
    # node classes
    classes = [ "base" ]
    klasses.sort.each do |klass|
      begin
        klassparameters = klass.parameters
        parameters = parameters.merge(klassparameters)
        classes << klass.name
        classes += klass.more_classes if klass.more_classes
      rescue Initr::Klass::ConfigurationError => e
        # if klass.parameters raises don't add klass to node
        err = "#{e.message} for node #{self.name}"
        logger.error(err) if logger
        # show message in puppet log
        classes << "configuration_errors"
        parameters["errors"]=[] unless parameters["errors"]
        parameters["errors"] << err unless parameters["errors"].include? err
      end
    end
    result = { }
    result["parameters"] = parameters
    result["classes"] = classes.uniq
    result
  end

  def after_create
    b = Initr::Base.new
    self.klasses << b
  end
  
  def after_save
    if puppet_host.nil?
      Delayed::Job.enqueue Initr::DelayedJob::AutosignJob.new
      # Delete node and autosign file after 48h if node still not connected to puppetmaster
      Delayed::Job.enqueue(Initr::DelayedJob::DeleteHostJob.new(id),0,((ActiveRecord::Base.default_timezone == :utc) ?
                                                                       Time.now.utc + 172800 : Time.now + 172800))
    end
  end

  def after_destroy
    Delayed::Job.enqueue Initr::DelayedJob::PuppetcaCleanJob.new(fqdn) unless puppet_host.nil?
    puppet_host_destroy
  end

  def <=>(oth)
    self.name <=> oth.name
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
    @host_object = Puppet::Rails::Host.find_by_name(name)
    Puppet::Rails::Host.destroy @host_object if @host_object
  end

  def puppet_fact(factname, default=nil)
    begin
      puppet_host.fact(factname).first.value
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
    f = puppet_fact('operatingsystem','FedoraCore') unless f
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

  def domain
    puppet_fact("domain", (name.split(".").last 2).join(".") )
  end

  def fqdn
    puppet_fact("fqdn", name)
  end

  def reverse_fqdn
    self.fqdn.split(".").reverse.join("_")
  end

  def ip
    puppet_attribute('ip')
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
    rescue Exception => e
        ''
    end

  end

  def kernel
    begin
      a = puppet_fact('kernelrelease').split(/\.|-|mdk/)
        "#{a[0]}.#{a[1]}.#{a[2]}-#{a[3]}"
    rescue Exception => e
        ''
    end
  end

end
