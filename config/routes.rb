match '/node/:action(/:id)' => 'node'
match '/nodes' => 'node#list'
match '/reports' => 'node#store_report',  :via => 'post'
match '/klass/:action/:id' => 'klass'
match '/install/:action/:id' => 'klass'

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
