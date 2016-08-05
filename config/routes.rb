match '/node/:action(/:id)' => 'node', :via => [:get, :post]
match '/nodes' => 'node#list', :via => :get
match '/reports' => 'node#store_report',  :via => 'post'
match '/klass/:action/:id' => 'klass', :via => [:get, :post, :patch]
# http://stackoverflow.com/questions/5369654/why-do-routes-with-a-dot-in-a-parameter-fail-to-match
match '/:id/install/:action' => 'install', :constraints => { :id => /[^\/]+/ }, :as => 'install', :via => :get

Dir.glob File.expand_path("plugins/initr/puppet/modules/*", Rails.root) do |plugin_dir|
  file = File.join(plugin_dir, "config/routes.rb")
  if File.exists?(file)
    begin
      instance_eval File.read(file)
    rescue Exception => e
      puts "Intr plugin: An error occurred while loading the routes definition of #{File.basename(plugin_dir)} plugin (#{file}): #{e.message}."
      exit 1
    end
  end
end
