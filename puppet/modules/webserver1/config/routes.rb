ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => 'webserver1' do |webserver1_routes|
    webserver1_routes.with_options :conditions => { :method => [:get,:post] } do |webserver1_views|
      webserver1_views.connect 'webserver1/:action/:id'
    end
  end
  map.with_options :controller => 'web_backups_server' do |webserver1_routes|
    webserver1_routes.with_options :conditions => { :method => [:get,:post] } do |webserver1_views|
      webserver1_views.connect 'web_backups_server/:action/:id'
    end
  end
end
