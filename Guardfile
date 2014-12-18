# A sample Guardfile
# More info at https://github.com/guard/guard#readme

H="plugins/initr"

guard :minitest, :zeus => true, :all_on_start => false, :all_after_pass => false, :test_folders => ["#{H}/test"] do
  watch(%r{^#{H}/lib/(.+)\.rb$})                          { |m| "#{H}/test/#{m[1]}_test.rb" }
  watch(%r{^#{H}/lib/initr/(.+)\.rb$})                    { |m| "#{H}/test/lib/#{m[1]}_test.rb" }
  watch(%r{^#{H}/app/models/(.+)\.rb$})                   { |m| "#{H}/test/unit/#{m[1]}_test.rb" }
  watch(%r{^#{H}/app/controllers/(.+)\.rb$})              { |m| "#{H}/test/functional/#{m[1]}_test.rb" }
  watch(%r{^#{H}/app/views/.+\.erb$})                     { ["#{H}/test/functional", "#{H}/test/integration"] }
  watch(%r{^#{H}/test/.+_test\.rb$})
  watch("#{H}/app/controllers/application_controller.rb") { ["#{H}/test/functional", "#{H}/test/integration"] }
  watch("#{H}/test/test_helper.rb")                       { "#{H}/test" }
end

#notification :notifysend
notification :libnotify
