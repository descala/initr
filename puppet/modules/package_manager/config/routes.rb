ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => 'package_manager' do |package_manager_routes|
    package_manager_routes.with_options :conditions => { :method => [:get,:post] } do |package_manager_views|
      package_manager_views.connect 'package_manager/:action/:id'
    end
  end
end
