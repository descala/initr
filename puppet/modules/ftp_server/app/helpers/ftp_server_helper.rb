module FtpServerHelper

  # TODO redmine2
  def add_user_link(server_form)
#    @klass.ftp_users.build if @klass.ftp_users.nil? or @klass.ftp_users.size == 0
    fields = server_form.fields_for('ftp_users', Initr::FtpUser.new, :child_index => 'new_ftp_users') do |builder|
      render('ftp_user', :f => builder)
    end
    link_to_function('Add user', "add_fields(this, \"#{escape_javascript(fields)}\")")
  end

end
