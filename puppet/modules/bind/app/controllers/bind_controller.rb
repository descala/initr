class BindController < ApplicationController
  
  unloadable

  before_filter :find_bind, :except => [:edit_zone,:destroy_zone]
  before_filter :find_bind_zone, :only => [:edit_zone,:destroy_zone]
  before_filter :authorize

  layout "nested"

  menu_item :initr

  def configure
    if request.post?
      params["bind"] ||= {}
      if @bind.update_attributes(params["bind"])
        flash[:notice]='Configuration saved'
        redirect_to :controller=>'klass', :action=>'list', :id=>@node
      else
        render :action=>'configure'
      end
    end
  end

  def add_zone
    @bind_zone = Initr::BindZone.new(params[:bind_zone])
    @bind_zone.bind = @bind
    if request.post?
      if @bind_zone.save
        flash[:notice]="Bind zone saved"
        redirect_to :action=>'configure', :id=>@bind
      else
        render :action=>"add_zone"
      end
    end
  end

  def edit_zone
    if request.post?
      if @bind_zone.update_attributes(params[:bind_zone])
        flash[:notice]="Bind zone saved"
        redirect_to :action => 'configure', :id => @bind
      else
        render :action => 'edit_zone'
      end
    end
  end

  def destroy_zone
    @bind_zone.destroy if request.post?
    redirect_to :action => 'configure', :id => @bind
  end

  private

  def find_bind
    @bind = Initr::Bind.find params[:id]
    @node = @bind.node
    @project = @node.project
  end

  def find_bind_zone
    @bind_zone = Initr::BindZone.find params[:id]
    @bind = @bind_zone.bind
    @node = @bind.node
    @project = @node.project
  end

end
