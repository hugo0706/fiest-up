# frozen_string_literal: true

class AccountsController < ApplicationController
  before_action :authorize

  def index
    @user = current_user
  end
  
  def destroy
    current_user.destroy
    
    flash[:notice] = 'Account deleted'
    redirect_to start_path
  end
  
  def logout
    current_session.expire!
    session[:session_token] = nil
    flash[:notice] = 'Session closed'
    redirect_to start_path
  end
end
