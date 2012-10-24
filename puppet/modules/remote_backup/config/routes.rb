ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => 'remote_backup' do |remote_backup_routes|
    remote_backup_routes.with_options :conditions => { :method => [:get,:post] } do |remote_backup_views|
      remote_backup_views.connect 'remote_backup/:action/:id'
    end
  end
  map.with_options :controller => 'remote_backup_server' do |remote_backup_routes|
    remote_backup_routes.with_options :conditions => { :method => [:get,:post] } do |remote_backup_views|
      remote_backup_views.connect 'remote_backup_server/:action/:id'
    end
  end
end
