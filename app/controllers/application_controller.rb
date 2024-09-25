# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  include ErrorHandler
  helper_method :logged_in?

  def not_found_method
    render file: Rails.public_path.join("404.html"), status: :not_found, layout: false
  end

  def logged_in?
    !!current_user
  end

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def authorize
    redirect_to start_path unless current_user
  end
end
