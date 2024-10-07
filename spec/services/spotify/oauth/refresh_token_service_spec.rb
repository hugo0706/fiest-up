# frozen_string_literal: true

require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Spotify::Oauth::RefreshTokenService do
  let(:refresh_token) { 'test_refresh_token' }

  subject { described_class.new(refresh_token) }

  describe '#initialize' do
    it 'initializes with a refresh token' do
      expect(subject.refresh_token).to eq(refresh_token)
    end
  end

  describe '#call' do
    let(:refresh_token_url) { 'https://accounts.spotify.com/api/token' }
    let(:client_id) { 'client_id' }
    let(:client_secret) { 'client_secret' }
    let(:user_scopes) { %w[user-read-private user-read-email user-read-playback-state] }
    let(:refresh_token_response) do
      {
        "access_token" => "mock_access_token",
        "token_type" => "Bearer",
        "expires_in" => 3600,
        "scope" => "#{user_scopes.join(' ')}"
      }.to_json
    end

    before do
      stub_const('Spotify::Oauth::RefreshTokenService::CLIENT_ID', client_id)
      stub_const('Spotify::Oauth::RefreshTokenService::CLIENT_SECRET', client_secret)
    end

    before do
      stub_request(:post, refresh_token_url)
        .with(
          body: {
            grant_type: 'refresh_token',
            refresh_token: refresh_token
          },
          headers: {
            'Authorization' => "Basic #{Base64.strict_encode64("#{client_id}:#{client_secret}")}",
            'Content-Type' => 'application/x-www-form-urlencoded'
          }
        )
        .to_return(status: 200, body: refresh_token_response, headers: { 'Content-Type' => 'application/json' })
    end

    it 'sends a POST request to the Spotify API and returns a hash with access token information' do
      response = subject.call

      expect(response).to eq(JSON.parse(refresh_token_response))
    end

    it 'sends a POST request to the Spotify API with basic auth' do
      subject.call

      expect(WebMock).to have_requested(:post, refresh_token_url)
        .with(
          headers: {
            'Authorization' => "Basic #{Base64.strict_encode64("#{client_id}:#{client_secret}")}"
          }
        )
    end

    context 'when Faraday request raises an exception' do
      let(:conn) { double(Faraday::Connection) }

      before { allow(subject).to receive(:conn).and_return(conn) }

      it 'raises Spotify::OauthError' do
        allow(conn).to receive(:post).and_raise(Faraday::Error)
        expect { subject.call }.to raise_error(Spotify::OauthError)
      end
    end
  end
end
