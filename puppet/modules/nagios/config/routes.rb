match '/nagios/:action/:id' => 'nagios', :via => [:get, :post, :patch]
match '/nagios_server/:action/:id' => 'nagios_server', :via => [:get, :post, :patch]
