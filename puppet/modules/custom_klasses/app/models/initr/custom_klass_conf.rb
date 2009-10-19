class Initr::CustomKlassConf < ActiveRecord::Base

  unloadable

  belongs_to :klass, :class_name => "Initr::CustomKlass"
  validates_presence_of :name, :value
  validates_uniqueness_of :name, :scope => :custom_klass_id

  def value_yaml
    read_attribute("value")
  end

  def value
    begin
      v = YAML.load read_attribute("value")
      if (v.class == String)
        val = read_attribute("value")
      elsif (v.class == FalseClass)
        val = "false"
      elsif (v.class == TrueClass)
        val = "true"
      elsif (v.class == Hash)
        val = hash_to_s(v)
      elsif (v.class == NilClass)
        val = nil
      else
        val = v.to_json
      end
    rescue Exception=>e
      val = read_attribute("value")
    end
    return "" if val.nil?
    return val.gsub(/"/, "'")
  end

  def value=(v)
    begin
      v2 = eval(v).to_yaml
      # to avoid converting some strings to number (ex. "2_3")
      if eval(v).class == Fixnum
        v2=eval(v.to_json) unless v =~ /^[0-9]+$/
      end
    rescue Exception=>e
      v2 = v
    end
    write_attribute("value", v2)
  end

  def <=>(oth)
    self.name <=> oth.name
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
