module NodeHelper
  
  def initr_project_path(project)
    b = []
    ancestors = (project.root? ? [] : project.ancestors.visible.to_a)
    ancestors.shift
    ancestors.push project
    b += ancestors.collect {|p| link_to(h(p), {:controller => 'projects', :action => 'show', :id => p, :jump => current_menu_item}, :class => 'ancestor') }
    b.join(' &#187; ').html_safe
  end
  
end
