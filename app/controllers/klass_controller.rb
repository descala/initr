class KlassController < ApplicationController
  unloadable

  before_filter :find_node, :only => [:list,:create,:add]
  before_filter :find_project, :only => [:configure,:destroy]
  before_filter :authorize
  
  layout 'nested' 
  
  def list
    @klass_names = Initr::KlassName.find :all, :order => "name"
    @klasses=@node.klasses
    @available_klass_names = @klass_names - @node.klass_names
    @facts = @node.puppet_host.get_facts_hash rescue []
  end
 
  def create
    @klass_name = Initr::KlassName.find params[:klass_name]
    begin
      # Exists a class named after the klass_name
      begin
        # try old naming of plugin models,
        # until we migrate all them to initr namespace
        klass = Kernel.const_get("Initr#{@klass_name.name.camelize}").new
      rescue NameError
        klass = Kernel.eval("Initr::"+@klass_name.name.camelize).new
      end
    rescue NameError
      # Default
      klass = Initr::Klass.new
    end
    klass.node=@node
    klass.klass_name=@klass_name
    if klass.save
      if klass.configurable?
        redirect_to :controller => klass.controller, :action => 'configure', :id => klass.id
      else
        redirect_to :action => 'list', :id => @node.id
      end
    else
      flash[:error] = "Error adding class: #{klass.error}"
      redirect_to :back
    end
  end

  def configure
    @confs = @klass.node.getconfs
    if request.post?
      save_confs(@klass)
      redirect_to :action => 'list', :id => @node.id
    end
  end
  
  def destroy
    k = Initr::Klass.find params[:id]
    k.confs.each do |c|
      c.destroy
    end
    k.destroy
    redirect_to :back
  end
    
  private
  
  def save_confs(k)
    params[:nodeconfs].split.each do |nc|
      value=params[nc]
      cn = Initr::ConfName.find_by_name nc
      c = Initr::Conf.find(:all, :conditions => ["conf_name_id = ? and klass_id = ?", cn.id, k.id])
      #TODO: raise if c.size > 1 ???
      c = (c.size == 1) ? c[0] : Initr::Conf.new()
      c.klass=k
      c.conf_name=cn
      c.set_value value
      c.save
    end
  end

  def find_node
    @node = Initr::Node.find params[:id]
    @project = @node.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_project
    @klass = Initr::Klass.find params[:id]
    @node = @klass.node
    @project = @node.project
  end
  
end
