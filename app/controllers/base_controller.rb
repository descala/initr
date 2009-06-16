class BaseController < ApplicationController
  unloadable

  layout 'nested'
  menu_item :initr

  before_filter :find_base
  before_filter :authorize

  def configure
    if request.post?
      params[:base][:existing_base_conf_attributes] ||= {}
      if @base.update_attributes(params[:base])
        flash[:notice] = "Configuration successfully updated."
        redirect_to :controller => 'klass', :action => 'list', :id => @node
      else
        render :action => 'configure'
      end
    end 
  end

  private

  def find_base
    @base = Initr::Base.find(params[:id])
    @node = @base.node
    @project = @node.project
  end
  
end
