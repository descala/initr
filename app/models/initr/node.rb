require 'puppet/rails/host'
require 'user'
require 'date'

class Initr::Node < ActiveRecord::Base

  unloadable

  has_many :klasses, :dependent => :destroy, :class_name => "Initr::Klass"
  has_many :confs, :through => :klasses, :class_name => "Initr::Conf"
  belongs_to :project

  validates_presence_of :name
  validates_uniqueness_of :name
  
  attr_accessor :domini
  attr_accessor :fqdn
  attr_accessor :so

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
    klasses.each do |klass|
      parameters = parameters.merge(klass.parameters)
    end
    # node classes
    classes = [ "base" ]
    klasses.sort.each do |k|
      classes << k.name4puppet
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
    Puppet::Rails::Host.delete @host_object
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
    f=puppet_fact('lsbdistid','FedoraCore')
    logger.debug("OS= '#{f}'") if logger
    return f
  end

  def os_release
    puppet_fact('lsbdistrelease','?')
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

  def freshcheck_warning?
    begin
      (Time.now - puppet_attribute('last_freshcheck')) > 60 * 30
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

  def freshcheck
    begin
      remaining(puppet_attribute('last_freshcheck'))
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

  def set_fqdn
    self.domini = "" if self.domini.nil?
    self.name = "" if self.name.nil?
    self.name = self.name.to_s + "." + self.domini
    self.name.downcase!
  end

  def accepts_role?( role, user )
    if role == 'user'
      return user.node_ids.include?(self.id)
    elsif role == 'admin'
      return true
    end
  end


  # TODO
  # should be at lib
  # convert a Time object to +0d0h0m0s
  def remaining(time)
    intervals = [["d", 1], ["h", 24], ["m", 60], ["s", 60]]
    elapsed = Time.now - time
    tense = elapsed > 0 ? "" : "-"
    interval = 60*60*24
    parts = intervals.collect do |name, new_interval|
      interval = interval / new_interval
      number, elapsed = elapsed.abs.divmod(interval)
        "#{numbero_i}#{name}" if numbero_i>0
    end
      "#{tense}#{parts.join("")}"
  end

  def getconf(name)
    begin
      cn = Initr::ConfName.find_by_name name
      cv = (Initr::ConfValue.find :all, :conditions => [ "conf_name_id = ? AND node_id = ?", cn.id, self.id ], :limit => 1).first
    rescue
      cv = nil
    end
    return cv
  end

  # returns { confname1 => conf1, ..., confnameN => confN }
  def getconfs
    configs = {}
    self.custom_klasses.each do |k|
      k.confs.each do |c|
        configs[c.conf_name.name] = c.get_value
      end
    end
    return configs
  end

  def get_conf(name)
    self.custom_klasses.each do |k|
      k.confs.each do |c|
        return c if c.conf_name.name == name
      end
    end
    return nil
  end

  def get_klass(name)
    klass_name = name.is_a?(Initr::KlassName) ? name : klass_name = Initr::KlassName.find_by_name(klass_name)
    begin
      (Initr::Klass.find :all, :conditions => [ "node_id=? and klass_name_id=?", self.id, klass_name.id ], :limit => 1).first
    rescue  ActiveRecord::SubclassNotFound
      klass_name.name += " (plugin missing!)"
      dummy = Initr::Klass.new
      dummy.klass_name = klass_name
      return dummy
    end
  end

  def custom_klasses
    self.klasses.collect {|k| k if k.class == Initr::CustomKlass }.compact
  end
end
