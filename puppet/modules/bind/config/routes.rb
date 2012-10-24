ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => 'bind' do |bind_routes|
    bind_routes.with_options :conditions => { :method => [:get,:post] } do |bind_views|
      bind_views.connect 'bind/:action/:id'
    end
  end
end
