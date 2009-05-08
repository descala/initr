class ConfNamesController < InitrRequireAdminController
  unloadable

  layout "base"

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @conf_name_pages = Paginator.new(self, Initr::ConfName.count, 50, params[:page])
    @conf_names = Initr::ConfName.find :all,
                                :limit => @conf_name_pages.items_per_page,
                                :offset => @conf_name_pages.current.offset
  end

  def show
    @conf_name = Initr::ConfName.find(params[:id])
  end

  def new
    @conf_name = Initr::ConfName.new
  end

  def create
    @conf_name = Initr::ConfName.new(params[:conf_name])
    if @conf_name.save
      flash[:notice] = 'Initr::ConfName was successfully created.'
      redirect_to :action => 'list', :id => @project
    else
      render :action => 'new'
    end
  end

  def edit
    @conf_name = Initr::ConfName.find(params[:id])
  end

  def update
    @conf_name = Initr::ConfName.find(params[:id])
    if @conf_name.update_attributes(params[:conf_name])
      flash[:notice] = 'Initr::ConfName was successfully updated.'
      redirect_to :action => 'show', :id => @conf_name
    else
      render :action => 'edit'
    end
  end

  def destroy
    Initr::ConfName.find(params[:id]).destroy
    redirect_to :action => 'list', :id => @project
  end

end
