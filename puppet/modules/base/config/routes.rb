ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => 'base' do |base_routes|
    base_routes.with_options :conditions => { :method => [:get,:post] } do |base_views|
      base_views.connect 'base/:action/:id'
    end
  end
end
