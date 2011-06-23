require "fileutils"

# Load initr plugins rake tasks
Dir["#{RAILS_ROOT}/vendor/plugins/initr/puppet/modules/*/rails_lib/tasks/**/*.rake"].sort.each { |ext| load ext }

namespace :initr do
  namespace :module do
    desc "Creates skel directories and files for a puppet module"
    task :create => :environment do
      name = ENV['name']
      modulesdir="#{File.dirname(__FILE__)}/../../puppet/modules"
      modules=Dir["#{modulesdir}/*"].collect {|d| d.split("/").last if File.directory? d}.compact
      if name.blank?
        puts "usage: rake initr:module:create name=<module_name>"
        exit
      end
      if modules.include? name
        puts "#{name} already exists on puppet/modules/ directory"
        exit
      end
      puts "Creating #{name} plugin"
      plugindir="#{modulesdir}/#{name}"
      puts "      create  vendor/plugins/initr/puppet/modules/#{name}/app/models/#{name}"
      FileUtils.mkdir_p("#{plugindir}/app/models/initr")
      puts "      create  vendor/plugins/initr/puppet/modules/#{name}/app/views/#{name}"
      FileUtils.mkdir_p("#{plugindir}/app/views/#{name}")
      puts "      create  vendor/plugins/initr/puppet/modules/#{name}/app/controllers"
      FileUtils.mkdir("#{plugindir}/app/controllers")
      puts "      create  vendor/plugins/initr/puppet/modules/#{name}/db/migrate"
      FileUtils.mkdir_p("#{plugindir}/db/migrate")
      puts "      create  vendor/plugins/initr/puppet/modules/#{name}/files"
      FileUtils.mkdir("#{plugindir}/files")
      puts "      create  vendor/plugins/initr/puppet/modules/#{name}/manifests"
      FileUtils.mkdir("#{plugindir}/manifests")
      puts "      create  vendor/plugins/initr/puppet/modules/#{name}/manifests/init.pp"
      open("#{plugindir}/manifests/init.pp", 'w') do |f|
        f << "class #{name} {\n"
        f << "\n"
        f << "}\n"
      end
      puts "      create  vendor/plugins/initr/puppet/modules/#{name}/templates"
      FileUtils.mkdir("#{plugindir}/templates")
      puts "      create  vendor/plugins/initr/puppet/modules/#{name}/app/models/initr/#{name}.rb"
      open("#{plugindir}/app/models/initr/#{name}.rb", 'w') do |f|
        f << "class Initr::#{name.camelize} < Initr::Klass\n"
        f << "  unloadable\n"
        f << "\n"
        f << "end\n"
      end
      puts "      create  vendor/plugins/initr/puppet/modules/#{name}/app/views/#{name}/configure.html.erb"
      open("#{plugindir}/app/views/#{name}/configure.html.erb", 'w') do |f|
        f << "<%= klass_menu \"#{name.camelize}\" %>\n"
        f << "<p>(TODO)</p>\n"
      end
      puts "      create  vendor/plugins/initr/puppet/modules/#{name}/app/controllers/#{name}_controller.rb"
      open("#{plugindir}/app/controllers/#{name}_controller.rb", 'w') do |f|
        f << "class #{name.camelize}Controller < InitrController\n"
        f << "  unloadable\n"
        f << "\n"
        f << "  menu_item :initr\n"
        f << "\n"
        f << "  before_filter :find_#{name}\n"
        f << "  before_filter :authorize\n"
        f << "\n"
        f << "  private\n"
        f << "\n"
        f << "  def find_#{name}\n"
        f << "    @klass = Initr::#{name.camelize}.find params[:id]\n"
        f << "    @node = @klass.node\n"
        f << "    @project = @node.project\n"
        f << "  end\n"
        f << "\n"
        f << "end\n"
      end
      puts "      create  vendor/plugins/initr/puppet/modules/#{name}/init.rb"
      open("#{plugindir}/init.rb", 'w') do |f|
        f << "require 'redmine'\n"
        f << "\n"
        f << "RAILS_DEFAULT_LOGGER.info 'Starting #{name} plugin for Initr'\n"
        f << "\n"
        f << "Initr::Plugin.register :#{name} do\n"
        f << "  redmine do\n"
        f << "    name '#{name}'\n"
        f << "    author 'Ingent'\n"
        f << "    description '#{name.camelize} plugin for initr'\n"
        f << "    version '0.0.1'\n"
        f << "    project_module :initr do\n"
        f << "      permission :configure_#{name},\n"
        f << "        { :#{name} => [:configure] },\n"
        f << "        :require => :member\n"
        f << "    end\n"
        f << "  end\n"
        f << "  klasses '#{name}' => '#{name.camelize} node'\n"
        f << "end\n"
      end
    end
  end
end
