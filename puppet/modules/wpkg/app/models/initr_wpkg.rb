class InitrWpkg < Initr::Klass

  unloadable
  
  XML_PATH = File.expand_path("#{File.dirname(__FILE__)}/../../files/packages")
  
  class Package
    attr_reader :id, :name, :revision
    def initialize(id,name,revision)
      @id = id
      @name = name
      @revision = revision
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
      'wpkg_profiles' => { 'default' => config.keys },
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
        packages << Package.new(p.attributes['id'],p.attributes['name'],p.attributes['revision'])
      end
    end
    packages.sort
  end
 
end
