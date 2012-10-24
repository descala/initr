ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => 'custom_klass' do |custom_klass_routes|
    custom_klass_routes.with_options :conditions => { :method => [:get,:post] } do |custom_klass_views|
      custom_klass_views.connect 'custom_klass/:action/:id'
    end
  end
end
