class BindController < InitrController
  
  unloadable

  before_filter :find_bind, :except => [:edit_zone,:destroy_zone]
  before_filter :find_bind_zone, :only => [:edit_zone,:destroy_zone]
  before_filter :authorize

  layout "nested"
  helper :initr
  menu_item :initr

  def configure
    if request.post?
      params["bind"] ||= {}
      if @klass.update_attributes(params["bind"])
        flash[:notice]='Configuration saved'
        redirect_to :action=>'configure'
      else
        render :action=>'configure'
      end
    end
  end

  def add_zone
    @bind_zone = Initr::BindZone.new(params[:bind_zone])
    @bind_zone.bind = @klass
    @zone_header = render_to_string(:partial=>'zone_header',:locals=>{:zone=>@bind_zone})
    if request.post?
      if @bind_zone.save
        flash[:notice]="Bind zone saved"
        redirect_to :action=>'configure', :id=>@klass
      else
        render :action=>"add_zone"
      end
    end
  end

  def edit_zone
    @zone_header = render_to_string(:partial=>'zone_header',:locals=>{:zone=>@bind_zone})
    if request.post?
      if @bind_zone.update_attributes(params[:bind_zone])
        flash[:notice]="Bind zone saved"
        redirect_to :action => 'configure', :id => @klass
      else
        render :action => 'edit_zone'
      end
    end
  end

  def destroy_zone
    @bind_zone.destroy if request.post?
    redirect_to :action => 'configure', :id => @klass
  end

  private

  def find_bind
    @klass = Initr::Bind.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

  def find_bind_zone
    @bind_zone = Initr::BindZone.find params[:id]
    @klass = @bind_zone.bind
    @node = @klass.node
    @project = @node.project
  end

end
