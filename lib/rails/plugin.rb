module Rails
  class Plugin
    def lib_path
      File.join(directory, 'rails_lib')
    end
  end
end
