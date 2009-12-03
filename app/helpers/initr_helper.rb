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

end
