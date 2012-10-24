ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => 'initr_wpkg' do |wpkg_routes|
    wpkg_routes.with_options :conditions => { :method => [:get,:post] } do |wpkg_views|
      wpkg_views.connect 'initr_wpkg/:action/:id'
    end
  end
end
