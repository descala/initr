match '/webserver1/:action/:id' => 'webserver1', :via => [:get, :post, :patch]
match '/web_backups_server/:action/:id' => 'web_backups_server', :via => [:get, :post, :patch]
