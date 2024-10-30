# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  include ErrorHandler
  helper_method :logged_with_spotify?
  helper_method :current_user

  def not_found_method
    render file: Rails.public_path.join("404.html"), status: :not_found, layout: false
  end

  def logged_with_spotify?
    !!current_user
  end
  
  def user_is_admin?
    current_user.admin? if current_user
  end

  private

  def current_session
    @current_session ||= Session.find_by(session_token: session[:session_token]) if session[:session_token]
  end

  def current_user
    @current_user ||= current_session.user if current_session.present? && !current_session.expired?
  end

  def authorize
    unless current_user
      flash[:error] = 'You need to log in with Spotify'
      redirect_to start_path 
    end
  end
end
