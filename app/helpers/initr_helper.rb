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
              {:controller=>'node', :action=>'report', :id=>report},
              :title => format_time(report.reported_at.getlocal))
    else
      image_tag("warning.png") + " never"
    end
  end

  def class_for(log_level)
    case log_level
    when :err then
      "report_err"
    when :warning then
      "report_warn"
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
    tabs = []
    if @node.is_a? Initr::NodeInstance and @node.puppet_host.nil?
      tabs << {:name => 'install', :partial => 'node/node', :label => :label_install }
    end
    tabs << {:name => 'klasses', :partial => 'node/klasses', :label => :label_klasses}
    tabs << {:name => 'external_nodes', :partial => 'node/external_nodes', :label => :label_external_nodes}
    unless @node.is_a? Initr::NodeTemplate
      tabs << {:name => 'exported_resources', :partial => 'node/exported_resources', :label => :label_exported_resources}
      tabs << {:name => 'facts', :partial => 'node/facts', :label => :label_facts}
      tabs << {:name => 'reports', :partial => 'node/reports', :label => :label_reports}
      unless @node.puppet_host.nil?
        tabs << {:name => 'install', :partial => 'node/node', :label => :label_reinstall }
      end
    end
    tabs
  end

  def help(topic, translate=true)
    content_tag("span",:class=>'help') do
      if translate
        image_tag('help.png', :title => l(topic))
      else
        image_tag('help.png', :title => topic)
      end
    end
  end

  def os_img(node)
    image_tag("os/#{node.os}.png", :title => "#{node.os} #{node.os_release} Kernel #{node.kernel}", :plugin => "initr") unless node.os.nil?
  end

end
