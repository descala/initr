class InitrRequireAdminController < ApplicationController
  unloadable

  before_filter :require_admin

end
  
  
