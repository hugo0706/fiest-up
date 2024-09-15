# frozen_string_literal: true

module Oauth
  class SessionsController < ApplicationController
    before_action :authorize, only: :logout

    def login
      state, oauth_url = Spotify::Oauth::AuthorizeService.new.get_state_and_authorize_url
      session[:oauth_state] = state

      redirect_to oauth_url, allow_other_host: true
    end
    
    def logout
      session[:oauth_state] = nil
      redirect_to start_path
    end

    def callback
      error, code, state = callback_params

      show_start_error if error.present?

      if code.present? && state.present? && state == session[:oauth_state]
        user = UserFetcherService.new(code).call
        session[:user_id] = user.id
        redirect_to home_path
      else
        show_start_error
      end

    rescue UserFetcherService::InvalidUserError,
          Spotify::Oauth::AccessTokenService::Error,
          Spotify::Api::CurrentProfileService::Error => e
      report_error(e)
      show_start_error
    end

    private

    def callback_params
      params.permit(:error, :code, :state).values_at(:error, :code, :state)
    end

    def show_start_error
      flash[:error] = "An unexpected error ocurred while login in"
      redirect_to start_path
    end
  end
end
