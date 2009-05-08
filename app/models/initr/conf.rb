class Initr::Conf < ActiveRecord::Base

  unloadable

  belongs_to :klass, :class_name => "Initr::Klass"
  belongs_to :conf_name, :class_name => "Initr::ConfName"

  def node
    self.klass.node
  end

  def klass_name
    self.conf_name.klass_name
  end

  def value_yaml
    read_attribute("value")
  end

  def get_value
    begin
      v = YAML.load read_attribute("value")
      if ( [String,FalseClass,TrueClass].include? v.class)
        val = read_attribute("value")
      elsif (v.class == Hash)
        val = hash_to_s(v)
      elsif (v.class == NilClass)
        val = nil
      else
        val = v.to_json
      end
    rescue
      val = read_attribute("value")
    end
    return "" if val.nil?
    return val.gsub(/"/, "'")
  end

  def set_value(v)
    begin
      v2 = eval(v).to_yaml
      # to avoid converting some strings to number (ex. "2_3")
      if eval(v).class == Fixnum
        v2=eval(v.to_json) unless v =~ /^[0-9]+$/
      end
    rescue
      v2 = v
    end
    write_attribute("value", v2)
  end

  def name
    self.conf_name.name
  end

  def <=>(oth)
    self.conf_name.name <=> oth.conf_name.name
  end

  private
  def hash_to_s(hash)
    s="{ \""
    hash.each do |k,v|
      s+=k.to_s+"\" => \""
      s+=v.to_s+"\", \""
    end
    s=s.chomp(", \"")+" }"
    return s
  end

end
