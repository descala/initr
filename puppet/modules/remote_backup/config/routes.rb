match '/remote_backup/:action/:id' => 'remote_backup', :via => [:get, :post]
match '/remote_backup_server/:action/:id' => 'remote_backup_server', :via => [:get, :post]
