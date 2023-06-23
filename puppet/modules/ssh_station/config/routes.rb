match '/ssh_station/:action/:id' => 'ssh_station', :via => [:get, :patch, :post]
match '/ssh_station_server/:action/:id' => 'ssh_station_server', :via => [:get, :patch]
