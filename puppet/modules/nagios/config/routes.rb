ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => 'nagios' do |nagios_routes|
    nagios_routes.with_options :conditions => { :method => [:get,:post] } do |nagios_views|
      nagios_views.connect 'nagios/:action/:id'
    end
  end
  map.with_options :controller => 'nagios_server' do |nagios_routes|
    nagios_routes.with_options :conditions => { :method => [:get,:post] } do |nagios_views|
      nagios_views.connect 'nagios_server/:action/:id'
    end
  end
end
