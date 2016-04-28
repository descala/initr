gem 'facter', :require => false

# Load initr plugins' Gemfiles
Dir.glob File.expand_path("../puppet/modules/*/Gemfile", __FILE__) do |file|
  puts "Loading #{file} ..." if $DEBUG # `ruby -d` or `bundle -v`
  #TODO: switch to "eval_gemfile file" when bundler >= 1.2.0 will be required (rails 4)
  instance_eval File.read(file), file
end
