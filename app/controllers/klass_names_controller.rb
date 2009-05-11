class KlassNamesController < InitrRequireAdminController
  unloadable

  helper :initr
  layout 'base' 

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    base = Initr::KlassName.find_by_name('base')
    @klass_name_pages = Paginator.new(self, Initr::KlassName.count, 50, params[:page])
    @klass_names = Initr::KlassName.find :all, :order => 'name',
                               :limit  =>  @klass_name_pages.items_per_page,
                               :offset =>  @klass_name_pages.current.offset,
                               :conditions => ["id != ?",base.id]
  end

  def show
    @klass_name = Initr::KlassName.find(params[:id])
    @conf_names = @klass_name.conf_names
  end

  def new
    @klass_name = Initr::KlassName.new
    @conf_names = Initr::ConfName.find :all
  end

  def create
    @klass_name = Initr::KlassName.new(params[:klass_name])
    confnames = Initr::ConfName.find :all
    needed_confnames = []
    i=0
    confnames.each do |ad|
      needed_confnames << params["confname_"+i.to_s]["id"] unless params["confname_"+i.to_s]["id"].length == 0
      i=i+1
    end
    @klass_name.conf_name_ids = needed_confnames
    if @klass_name.save
      flash[:notice] = 'Class successfully created.'
      redirect_to :action => 'list'
    else
      @conf_names = Initr::ConfName.find :all
      render :action => 'new'
    end
  end

  def edit
    @klass_name = Initr::KlassName.find(params[:id])
    @conf_names = Initr::ConfName.find :all
  end

  def update
    @klass_name = Initr::KlassName.find(params[:id])
    confnames = Initr::ConfName.find :all
    needed_confnames = []
    i=0
    confnames.each do |ad|
      needed_confnames << params["confname_"+i.to_s]["id"] unless params["confname_"+i.to_s]["id"].length == 0
      i=i+1
    end
    @klass_name.conf_name_ids=needed_confnames
    if @klass_name.update_attributes(params[:klass_name])
      flash[:notice] = 'Class successfully updated.'
      redirect_to :action => 'list', :id => @klass_name
    else
      render :action => 'edit'
    end
  end

  def destroy
    Initr::KlassName.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
end
