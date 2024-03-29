class CustomKlassController < InitrController

  menu_item :initr
  before_action :find_node,         :only => [:new,:create]
  before_action :find_custom_klass, :only => [:configure]
  before_action :authorize

  def new
    @klass = Initr::CustomKlass.new(:node=>@node)
  end

  def create
    if request.post?
      @klass = Initr::CustomKlass.new(params[:custom_klass])
      @klass.node = @node
      if @klass.save
        flash[:notice]='Configuration saved'
        redirect_to :controller=>'klass',:action=>'list',:id=>@node, :tab => 'klasses'
      else
        render :action=>'new', :id=>@node
      end
    else
      redirect_to :controller=>'klass', :action=>'list', :id=>@node, :tab=>'klasses'
    end
  end

  def configure
    @html_title=[@node.fqdn, @klass.name]
    if request.patch?
      if @klass.update_attributes(params[:custom_klass])
        flash[:notice]='Configuration saved'
      end
    end
  end

  private

  def find_node
    @node = Initr::Node.find params[:id]
    @project = @node.project
  end

  def find_custom_klass
    @klass = Initr::CustomKlass.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

end

