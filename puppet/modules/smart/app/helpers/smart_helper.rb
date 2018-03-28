module SmartHelper

  # TODO redmine2
  def add_drive_link()
    fields = render(:partial=>'drive')
    link_to_function('Add drive',"add_fields(this,\"#{escape_javascript(fields)}\")")
  end

end
