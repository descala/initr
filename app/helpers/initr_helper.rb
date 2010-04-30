module InitrHelper

  def color_zebra(i)
    i.modulo(2)==0 ? 'bglight' : 'bgdark'
  end

  def link_to_report(report)
    if report
      if report.error?
        img = "exclamation"
      elsif report.changes?
        img = "changeset"
      else
        img = "true"
      end
      link_to(image_tag("#{img}.png") + " " + time_ago_in_words(report.reported_at.getlocal),
              {:action=>'report', :id=>report},
              :title => format_time(report.reported_at.getlocal))
    else
      image_tag("warning.png") + " never"
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

  def klass_list_tabs
    tabs = [{:name => 'klasses', :partial => 'klass/klasses', :label => :label_klasses},
            {:name => 'external_nodes', :partial => 'klass/external_nodes', :label => :label_external_nodes}
           ]
    unless @node.is_a? Initr::NodeTemplate
      tabs << {:name => 'exported_resources', :partial => 'klass/exported_resources', :label => :label_exported_resources}
      tabs << {:name => 'facts', :partial => 'klass/facts', :label => :label_facts}
    end
    tabs
  end
  
end
