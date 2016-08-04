match '/nagios/:action/:id' => 'nagios', :via => [:get, :post]
match '/nagios_server/:action/:id' => 'nagios_server', :via => [:get, :post]
