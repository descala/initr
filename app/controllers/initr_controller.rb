class InitrController < ApplicationController
  unloadable

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

end
