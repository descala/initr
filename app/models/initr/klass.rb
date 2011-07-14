class Initr::Klass < ActiveRecord::Base

  # raised in parameters when there's a configuration error
  # and klass should not be included in node parameters
  # (see parameters method in Initr::Node class)
  class ConfigurationError < StandardError ; end

  unloadable

  belongs_to :node, :class_name => "Initr::Node"

  after_save :add_klasses, :trigger_puppetrun
  after_destroy :trigger_puppetrun
  validates_uniqueness_of :type, :scope => :node_id , :if => Proc.new { |k| k.unique? }

  serialize :config

  @@adds_klasses = false

  def initialize(attributes = nil)
    super
    self.config ||= {}
    self.active = self.valid? if self.active.nil?
    self.errors.clear
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
  def puppetname
    self.name
  end

  def name
    self.class.to_s.split('::').last.underscore
  end

  # you should override this method and return a description for the class
  def description
  end

  def controller
    class_name = self.class.to_s.split('::').last
    if "#{class_name}Controller".constantize.instance_methods.include? 'configure'
      class_name.underscore
    else
      'klass'
    end
  rescue NameError => e
    'klass'
  end

  # Variables for puppet
  def parameters
    return {} unless self.config.is_a? Hash
    self.config
  end

  # merges an existing parameter
  def merge_parameter(key,current_value)
    if current_value.class == Array
      # add value if current value is an array
      current_value << self.parameters[key]
      current_value.flatten!
    elsif current_value.class == Hash
      # merge if it is a hash
      current_value.merge!(self.parameters[key])
    elsif current_value != self.parameters[key]
      # otherwise create an array, if values differ
      current_value = [current_value, self.parameters[key]]
      current_value.flatten!
    end
    return current_value
  end

  # Array of additional puppet classes that should be included
  def more_classes
    nil
  end

  # a class can be moved from node to another
  def movable?
    true
  end

  # a class can be removed from a node
  def removable?
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
    self.node.puppet_fact('puppet_classes','').split.include? self.puppetname
  end

  def active?
    active
  end

  def self.accessors_for(attributes)
    attributes.each do |c|
      src = <<-END_SRC
      def #{c}
        config["#{c}"]
      end

      def #{c}=(v)
        config["#{c}"] = v
      end
      END_SRC
      class_eval src, __FILE__, __LINE__
    end
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

  def trigger_puppetrun
    # uncomment on rails 3, rails 2.3 does not detect changes on serialized columns
    # https://rails.lighthouseapp.com/projects/8994/tickets/360-dirty-tracking-on-serialized-columns-is-broken
    # return unless self.changed?
    return unless self.valid?
    begin
      open("public/puppetrun_#{self.node.name}",'w') {|f| f << Time.now.to_i }
    rescue
    end
  end

end

