match '/dyndns/:action/:id' => 'dyndns', via: [:get, :patch]
match '/nic/update' => 'dyndns#update', via: :get
