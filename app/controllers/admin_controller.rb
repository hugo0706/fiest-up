class AdminController < ApplicationController
  before_action :authenticate_admin!
  
  
  private
  
  def authenticate_admin!
    unless user_is_admin?
      flash[:error] = "Access denied"
      redirect_to main_app.start_path
    end
  end
end