match '/nagios/:action/:id' => 'nagios', :via => [:get, :post, :put]
match '/nagios_server/:action/:id' => 'nagios_server', :via => [:get, :post, :put]
