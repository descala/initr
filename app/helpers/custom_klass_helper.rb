module CustomKlassHelper

  def add_ckc_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, :custom_klass_confs, :partial => 'custom_klass_conf' , :object => Initr::CustomKlassConf.new
    end
  end
  
end
