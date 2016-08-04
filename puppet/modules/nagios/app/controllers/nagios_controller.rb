class NagiosController < InitrController

  menu_item :initr
  before_filter :find_nagios, :except => [:edit_check, :update_check, :destroy_check, :before_destroy_check]
  before_filter :find_nagios_check, :only => [:edit_check, :update_check, :destroy_check, :before_destroy_check]
  before_filter :authorize

  def configure
    @html_title=[@node.fqdn, @klass.name]
    @nagios_servers = Initr::NagiosServer.all.collect {|ns|
      ns if User.current.projects.include? ns.node.project or User.current.admin?
    }.compact
    if request.post? or request.put?
      if @klass.update_attributes(params[:nagios])
        flash[:notice] = 'Configuration successfully updated.'
        redirect_to :action => 'configure'
      else
        render :action => 'configure'
      end
    end
  end

  def new_check
    @nagios_check = Initr::NagiosCheck.new
  end

  def create_check
    @nagios_check = Initr::NagiosCheck.new(params[:nagios_check])
    if request.post?
      if @nagios_check.save
        flash[:notice] = "Nagios check configured."
        redirect_to :action => 'configure', :id => @klass
      else
        render :action => 'new_check'
      end
    end
  end

  def update_check
    if @nagios_check.update_attributes(params[:nagios_check])
      flash[:notice] = "Nagios check successfully updated."
      redirect_to :action => 'configure', :id => @klass
    else
      render :action => 'edit_check'
    end
  end

  def before_destroy_check
    if request.post?
      @nagios_check.ensure = "absent"
      @nagios_check.save(:validate => false)
    end
    redirect_to :action => 'configure', :id => @klass
  end

  def destroy_check
  end

  def add_check
    check = @klass.recomended_checks[params["check"]]
    @nagios_check = Initr::NagiosCheck.new(:name=>params["check"],:command=>check)
    render :action => 'new_check'
  end

  private

  def find_nagios
    @klass = Initr::Nagios.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

  def find_nagios_check
    @nagios_check = Initr::NagiosCheck.find params[:id]
    @klass = @nagios_check.nagios
    @node = @klass.node
    @project = @node.project
  end

end
