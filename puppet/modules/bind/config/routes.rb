match '/bind/:action/:id' => 'bind', :via => [:get, :post, :patch]

# My DNS — self-service zone editing (see MyZonesController). No :as names —
# this file is loaded twice (initr glob + zzz_bind symlink), so named routes collide.
get   '/my_dns'          => 'my_zones#index'
get   '/my_dns/:id/edit' => 'my_zones#edit'
patch '/my_dns/:id'      => 'my_zones#update'

# DNS assignments (admin only, see DnsAssignmentsController) — assign self-service
# users to the zones they may manage (assigned list + search-to-add). Same
# no-:as-names rule as above. /search must precede the :user_id routes so it is
# not swallowed; all path params are numeric (no domains), so no dot constraints.
get    '/dns_assignments'                         => 'dns_assignments#index'
get    '/dns_assignments/search'                  => 'dns_assignments#search'
post   '/dns_assignments/:user_id/zones'          => 'dns_assignments#add_zone'
delete '/dns_assignments/:user_id/zones/:zone_id' => 'dns_assignments#remove_zone'