# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Oauth::SessionsController, type: :controller do
  describe 'GET #login' do
    let(:user_scopes) { %w[user-read-private user-read-email] }
    let(:state) { 'securerandomstat' }
    let(:redirect_uri) { 'http://localhost:3000/auth/callback' }
    let(:client_id) { 'test_client_id' }

    before do
      stub_const('Oauth::SessionsController::SPOTIFY_CLIENT_ID', client_id)
      stub_const('Oauth::SessionsController::SPOTIFY_REDIRECT_URI', redirect_uri)
      allow(SecureRandom).to receive(:hex).with(16).and_return(state)
    end

    it 'redirects user to Spotify authorization endpoint' do
      expected_auth_url = "https://accounts.spotify.com/authorize?" \
                            "client_id=#{client_id}" \
                            "&redirect_uri=#{CGI.escape(redirect_uri)}" \
                            "&response_type=code" \
                            "&scope=#{user_scopes.join('+')}" \
                            "&state=#{state}"

      get :login

      expect(response).to redirect_to(expected_auth_url)
      expect(response.status).to eq(302)
    end
  end

  describe 'GET #callback' do
  end
end
