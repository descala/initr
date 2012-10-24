ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => 'fail2ban' do |fail2ban_routes|
    fail2ban_routes.with_options :conditions => { :method => [:get,:post] } do |fail2ban_views|
      fail2ban_views.connect 'fail2ban/:action/:id'
    end
  end
end
