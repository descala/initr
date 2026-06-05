match '/bind/:action/:id' => 'bind', :via => [:get, :post, :patch]
get    '/bind_zones/:id' => 'bind_records#index',  constraints: { id: /[^\/]+/ }
post   '/bind_zones/:id' => 'bind_records#create',  constraints: { id: /[^\/]+/ }
patch  '/bind_zones/:id' => 'bind_records#update',  constraints: { id: /[^\/]+/ }
delete '/bind_zones/:id' => 'bind_records#destroy', constraints: { id: /[^\/]+/ }
