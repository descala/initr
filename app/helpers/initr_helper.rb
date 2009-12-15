module InitrHelper

  def color_zebra(i)
    i.modulo(2)==0 ? 'bglight' : 'bgdark'
  end

  def current_state(node)
    if node.puppet_host.nil?
      content_tag(:span, 'Pending', :style=>'color: orange;', :title => 'The node has not contacted us yet')      
    else
      content_tag(:span, 'Correct', :style=>'color: green;')
    end
  end

  def klass_menu(title="")
    t = title.blank? ? "Configuration" : title
    render(:partial => 'klass/menu', :locals => {:title=>t})
  end
  
  def list_facts_like(obj,name='ipaddress_')
    facts = []
    if obj.is_a? Initr::Node and host=obj.puppet_host
      facts = host.fact_values.find(:all, :include => :fact_name,
                                    :conditions => "fact_names.name LIKE '#{name}%'")
    end
    out = ""
    facts.each do |fv|
      out << "#{fv.fact_name.name} = #{fv.value} <br/>"
    end
    out
  end
  
end
