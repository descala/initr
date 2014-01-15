module RedminePluginPatch
  def self.included(base)
    base.class_eval do
      def migration_directory
        File.join(directory, 'db', 'migrate')
      end
    end
  end
end
