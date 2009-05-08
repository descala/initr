# Load the normal Rails helper. This ensures the environment is loaded
require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')
# Ensure that we are using the temporary fixture path
Engines::Testing.set_fixture_path
