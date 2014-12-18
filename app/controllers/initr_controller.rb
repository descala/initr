class InitrController < ApplicationController
  unloadable

  # to make right menu appear
  layout "nested"

  # use initr helper
  helper :initr

  # make "initr" item on the top menu the selected one
  menu_item :initr

  # Authorize the user for the requested action
  def authorize(ctrl = params[:controller], action = params[:action], global = false)
    if @klass
      # if @klass variable is set, we are trying to edit a node
      deny_access unless @klass.node.editable_by?(User.current)
    elsif ctrl == "node" && action == "destroy"
      deny_access unless @node.removable_by?(User.current)
    else
      super
    end
  end

  def index
    redirect_to :controller => 'node', :action => 'list'
  end

  def configure
    @html_title=[@node.fqdn, @klass.name]
    if request.post? or request.put?
      if @klass.update_attributes(params[@klass.params_name])
        flash[:notice] = "#{@klass.name.capitalize} configuration successfully updated."
      end
    end
  end

end
