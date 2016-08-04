class InitrWpkg < Initr::Klass

  
  XML_PATH = File.expand_path("#{File.dirname(__FILE__)}/../../files/packages")
  
  class Package
    attr_reader :id, :name, :revision,:help
    def initialize(id,name,revision,help)
      @id = id
      @name = name
      @revision = revision
      @help = help
    end
    def to_s
      "#{id} - #{name} (rev #{revision})"
    end
    def <=>(o)
      self.id <=> o.id
    end
  end

  def name
    "wpkg"
  end

  def parameters
    {
      'wpkg_profiles' => { 'default' => config.keys.sort },
      'wpkg_base' => '/var/arxiver/deploy'
    } 
  end

  def more_classes
    more_classes = []
    config.keys.each do |package|
      more_classes << "wpkg::#{package}"
    end
    more_classes
  end
  
  def print_parameters
    config.keys.join ", "
  end
  
  def self.packages_available_from_xml
    files = Dir.glob("#{XML_PATH}/*.xml").entries
    packages = []
    files.each do |file|
      xml = File.read(file)
      doc = REXML::Document.new(xml)
      doc.elements.each('packages/package') do |p|
        packages << Package.new(p.attributes['id'],p.attributes['name'],p.attributes['revision'],p.attributes['help'])
      end
    end
    packages.sort
  end
 
end
