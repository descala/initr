ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => 'link_klass' do |link_klass_routes|
    link_klass_routes.with_options :conditions => { :method => [:get,:post] } do |link_klass_views|
      link_klass_views.connect 'link_klass/:action/:id'
    end
  end
end
