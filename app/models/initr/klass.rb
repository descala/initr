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

  # add klasses to this variable to automatically add them on include
  # example: @@adds_klasses = [ Initr::PackageManager ]
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

  # this is the name of the puppet class
  # klasses override it
  def name
    self.class.to_s.split('::').last.underscore
  end

  # this is the name used in the params of forms
  def params_name
    self.class.to_s.split('::').join('_').downcase
  end

  def pretty_name
    name.camelize
  end

  # you should override this method and return a description for the class
  def description
  end

  def controller
    class_name = self.class.to_s.split('::').last
    if "#{class_name}Controller".constantize.respond_to? 'configure'
      class_name.underscore
    else
      'klass'
    end
  rescue NameError
    'klass'
  end

  # top scope variables
  #TODO: by default it returns klass.config, maybe should move this to class_parameters?
  def parameters
    return {} unless self.config.is_a? Hash
    self.config
  end

  # class scope variables
  # http://docs.puppetlabs.com/guides/parameterized_classes.html
  def class_parameters
    nil
  end

  def self.merge_parameters(current_hash, new_hash)
    return new_hash if current_hash.nil?
    new_hash.each do |k,v|
      if current_hash[k]
        current_hash[k] = Initr::Klass.merge_parameter(current_hash[k],v)
      else
        current_hash[k] = v
      end
    end
    current_hash
  end

  # merges an existing parameter
  def self.merge_parameter(current_value, new_value)
    if current_value.class == Array
      # add value if current value is an array
      current_value << new_value
      current_value.flatten!
    elsif current_value.class == Hash
      # merge if it is a hash
      current_value.merge!(new_value)
    elsif current_value != new_value
      # otherwise create an array, if values differ
      current_value = [current_value, new_value]
      current_value.flatten!
    end
    return current_value
  end

  # Array of additional puppet classes that should be included
  def more_classes
    []
  end

  # a class can be moved from node to another
  def movable?
    true
  end

  # a class can be copied from node to another
  def copyable?
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

  # return a partial name to render it on node/list
  # (see app/views/node/_node_line.html.erb)
  def nodelist_partial
    false
  end

  # override this method if klass defines other relationships
  def clone
    self.class.new(self.attributes)
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

