ActionController::Routing::Routes.draw do |map|
  map.nodes '/nodes', :controller => 'node', :action => 'list'
  map.nodes '/reports', :controller => 'node', :action => 'store_report', :format => 'yml'
end
