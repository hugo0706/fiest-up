# frozen_string_literal: true

module Oauth
  class SessionsController < ApplicationController
    before_action :authorize, only: :logout
    before_action :check_user_joining_party, only: :callback
    before_action :validate_oauth_state, only: :callback

    def login
      state, oauth_url = Spotify::Oauth::AuthorizeService.new.get_state_and_authorize_url
      session[:oauth_state] = state

      redirect_to oauth_url, allow_other_host: true
    end

    def logout
      session[:user_id] = nil
      redirect_to start_path
    end

    def callback
      # TODO: change this joining party code flow to be stored in cache with expiricy
      # and remove related cookie when expiring to prevent cookie existing in next visit

      error, code, state = callback_params

      user = UserFetcherService.new(code).call

      session[:user_id] = user.id

      if @joining_party_code.present?
        flash[:notice] = "Joining party with your Spotify account!"
        redirect_to join_party_path(code: @joining_party_code)
      else
        flash[:notice] = "Logged in!"
        redirect_to home_path
      end
    rescue UserFetcherService::Error => e
      report_error(e)
      show_start_error
    end

    private

    def validate_oauth_state
      error, code, state = callback_params

      if code.present? && state.present? && state == session[:oauth_state] && error.nil?
        true
      else
        show_start_error
        nil
      end
    end

    def check_user_joining_party
      @joining_party_code = session[:joining_party_code]
      session[:joining_party_code] = nil
    end

    def callback_params
      params.permit(:error, :code, :state).values_at(:error, :code, :state)
    end

    def show_start_error
      flash[:error] = "An unexpected error ocurred while login in"
      redirect_to start_path
    end
  end
end
