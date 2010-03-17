class CopyKlassController < InitrController
  unloadable

  layout 'nested'
  helper :initr
  menu_item :initr

  before_filter :find_copy_klass

  def configure
    @copiable_klasses = []
    User.current.projects.collect {|p| p.nodes }.compact.flatten.sort.each do |node|
      next if node == @node
      n = [node.fqdn, node.klasses.collect {|k| [k.name,k.id.to_s] unless k.respond_to?(:copyable?) and !k.copyable? }.compact]
      @copiable_klasses << n unless n.last.size == 0
    end
    if request.post?
      params["copy_klass"] ||= {}
      if @klass.update_attributes(params["copy_klass"])
        flash[:notice]='Configuration saved'
        redirect_to :controller => 'klass', :action=>'list', :id => @node
      else
        render :action=>'configure'
      end
    end
  end

  def find_copy_klass
    @klass = Initr::CopyKlass.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

end
