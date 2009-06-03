class CustomKlassController < ApplicationController

  unloadable

  before_filter :find_node, :only  => [:new, :create]
  before_filter :find_klass, :only => [:configure]

  def new
    @klass_name = Initr::KlassName.new
    @conf_names = Initr::ConfName.all
  end

  def create
    #TODO: copy&pasted from KlassNamesController
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
      redirect_to :controller => 'klass', :action => 'list', :id => @node
    else
      @conf_names = Initr::ConfName.find :all
      render :action => 'new', :id => @node
    end
  end

  def configure
    @confs = @klass.node.getconfs
    if request.post?
      save_confs(@klass)
      redirect_to :action => 'list', :id => @node.id
    end
  end

  private

  def find_node
    @node = Initr::Node.find params[:id]
    @project = @node.project
  end

  def find_klass
    @klass = Initr::CustomKlass.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

end

