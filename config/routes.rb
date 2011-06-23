ActionController::Routing::Routes.draw do |map|
  map.nodes '/nodes', :controller => 'node', :action => 'list'
end
