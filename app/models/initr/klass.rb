class Initr::Klass < ActiveRecord::Base

  # raised in parameters when there's a configuration error
  # and klass should not be included in node parameters
  # (see parameters method in Initr::Node class)
  class ConfigurationError < StandardError ; end

  unloadable
  
  belongs_to :node, :class_name => "Initr::Node"
  
  after_save :add_klasses
  validates_uniqueness_of :type, :scope => :node_id , :if => Proc.new { |k| k.unique? }
  
  serialize :config
  
  @@adds_klasses = false
  
  def initialize(attributes = nil)
    super
    self.config ||= {}
  end

  # Default to only one klass type per node
  # see validates_uniqueness_of
  def unique?; true end
  
  # Returns the Initr::Klass of our type (STI) for a given node
  def self.for_node(node)
    node.klasses.find_by_type(self.sti_name)
  end
  
  # If your model class does not match your puppet class, you must override
  # this method and return a name for the class.
  # It must be a valid puppet class name, without strange characters or spaces
  def name
    self.class.to_s.gsub(/^Initr::/,'').underscore
  end

  # you should override this method and return a description for the class
  def description
  end

  def controller
    self.class.to_s.gsub(/^Initr::/,'').underscore
  end
  
  # Variables for puppet
  def parameters
    return {} unless self.config.is_a? Hash
    self.config
  end
  
  # Array of additional puppet classes that should be included
  def more_classes
    nil
  end
  
  # we assume that each class has a controller to configure it
  def configurable?
    true
  end
  
  # information to show about the conf of this class
  def print_parameters
    "-"
  end

  def <=>(oth)
    return -1 if self.name == 'base'
    return  1 if oth.name  == 'base'
    self.name.downcase <=> oth.name.downcase
  end

  def installed?
    self.node.puppet_fact('puppet_classes','').split.include? self.name
  end

  private

  def self.adds_klass(*args)
    @@adds_klasses = args
  end
  
  def add_klasses
    return unless @@adds_klasses
    @@adds_klasses.each do |k|
      if !self.node.klasses.find_by_type(k.to_s.split("::").last)
        self.node.klasses << k.new
      end
    end
  end

end

