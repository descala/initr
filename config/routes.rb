ActionController::Routing::Routes.draw do |map|

  map.with_options :controller => 'node' do |node_routes|
    node_routes.with_options :conditions => { :method => [:get,:post] } do |node_views|
      node_views.connect 'node/:action/:id'
      node_views.connect '/nodes', :action => 'list'
      node_views.connect '/reports', :action => 'store_report', :format => 'yml'
    end
  end

  map.with_options :controller => 'klass' do |klass_routes|
    klass_routes.with_options :conditions => { :method => [:get,:post] } do |klass_views|
      klass_views.connect 'klass/:action/:id'
    end
  end

  map.with_options :controller => 'install' do |install_routes|
    install_routes.with_options :conditions => { :method => [:get,:post] } do |install_views|
      install_views.connect 'install/:action/:id'
    end
  end

end
