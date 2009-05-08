class Initr::BaseConf < ActiveRecord::Base

  unloadable
  require "ostruct"

  ATTRIBUTES = ["initr_cron","initr_nsca_node"]

  belongs_to :base, :class_name => "Initr::Base"
  serialize :optshash

  def after_create
    self.optshash=OpenStruct.new(ATTRIBUTES) if read_attribute(:optshash).nil?
    save
  end

  def puppetconf
    opts = self.optshash.marshal_dump.stringify_keys
    opts.each do |k,v|
      opts.delete(k) if v.nil?
    end
    return opts
  end

  def optshash
    return OpenStruct.new(ATTRIBUTES) if read_attribute(:optshash).nil?
    return read_attribute(:optshash)
  end

  def respond_to?(m)
    return true if(ATTRIBUTES.include?(m.to_s) or ATTRIBUTES.include?(m.to_s.gsub(/=$/,'')))
    super(m)
  end

  protected

  def method_missing(m, *args)
    return read_attribute(:optshash).send(m,*args) if respond_to? m
    super
  end

end

