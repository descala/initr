# munin routes for redmine
match '/munin/:action/:id(/:period(/:graph))' => 'munin', :via => [:get, :patch]
match '/munin_server/:action/:id' => 'munin_server', :via => [:get, :patch]
