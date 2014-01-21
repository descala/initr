class LinkKlassController < InitrController
  unloadable

  menu_item :initr
  before_filter :find_node,       :except => [:configure]
  before_filter :find_link_klass, :only => [:configure]
  before_filter :set_copiable_klasses
  before_filter :authorize

  def new
    @klass = Initr::LinkKlass.new(:node=>@node)
  end

  def create
    if request.post?
      @klass = Initr::LinkKlass.new(params[:link_klass])
      @klass.node=@node
      if @klass.save
        flash[:notice]='Configuration saved'
        redirect_to :controller => 'klass', :action=>'list', :id=>@node, :tab=>'klasses'
      else
        render :action=>'new'
      end
    else
      redirect_to :controller=>'klass', :action=>'list', :id=>@node, :tab=>'klasses'
    end
  end

  def configure
    @html_title=[@node.fqdn, "#{@klass.name} (link klass)"]
    if request.post? or request.put?
      params["link_klass"] ||= {}
      if @klass.update_attributes(params["link_klass"])
        flash[:notice]='Configuration saved'
        redirect_to :controller => 'klass', :action=>'list', :id => @node, :tab=>'klasses'
      else
        render :action=>'configure'
      end
    end
  end

  private

  def find_link_klass
    @klass = Initr::LinkKlass.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

  def find_node
    @node = Initr::Node.find params[:id]
    @project = @node.project
  end

  def set_copiable_klasses
    @copiable_klasses = []
    User.current.projects.collect {|p| p.nodes }.compact.flatten.sort.each do |node|
      next if node == @node
      n = [node.fqdn, node.klasses.collect {|k| [k.name,k.id.to_s] if k.copyable? }.compact]
      @copiable_klasses << n unless n.last.size == 0
    end
  end

end
