module CustomKlassHelper

  # TODO redmine2
  def add_ckc_link(name,form)
    fields = form.fields_for('custom_klass_confs', Initr::CustomKlassConf.new, :child_index => 'new_custom_klass_conf') do |builder|
      render('custom_klass_conf', :f => builder)
    end
    link_to_function(name, "add_fields(this, \"#{escape_javascript(fields)}\")")
  end
  
end
