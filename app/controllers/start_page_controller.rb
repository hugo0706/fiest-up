# frozen_string_literal: true

class StartPageController < ApplicationController
  layout "start_page"

  def index
    redirect_to home_path if current_user
  end
end
