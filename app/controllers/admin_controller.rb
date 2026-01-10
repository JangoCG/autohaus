class AdminController < ApplicationController
  include Authorization

  before_action :ensure_admin
end
