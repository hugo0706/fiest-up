# frozen_string_literal: true

require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Spotify::Oauth::AccessTokenService do
  let(:authorization_code) { 'test_auth_code' }

  subject { described_class.new(authorization_code) }

  describe '#initialize' do
    it 'initializes with an authorization code' do
      expect(subject.code).to eq(authorization_code)
    end
  end

  describe '#call' do
    let(:access_token_url) { 'https://accounts.spotify.com/api/token' }
    let(:client_id) { 'client_id' }
    let(:client_secret) { 'client_secret' }
    let(:spotify_redirect_uri) { 'http://spotify.com' }
    let(:user_scopes) { %w[user-read-private user-read-email user-read-playback-state] }

    let(:access_token_response) do
      {
        "access_token" => "mock_access_token",
        "token_type" => "Bearer",
        "expires_in" => 3600,
        "refresh_token" => "mock_refresh_token",
        "scope" => "#{user_scopes.join(' ')}"
      }.to_json
    end

    before do
      stub_const('Spotify::Oauth::AccessTokenService::CLIENT_ID', client_id)
      stub_const('Spotify::Oauth::AccessTokenService::CLIENT_SECRET', client_secret)
      stub_const('Spotify::Oauth::AccessTokenService::SPOTIFY_REDIRECT_URI', spotify_redirect_uri)
    end

    before do
      stub_request(:post, access_token_url)
        .with(
          body: {
            grant_type: 'authorization_code',
            code: authorization_code,
            redirect_uri: spotify_redirect_uri
          },
          headers: {
            'Authorization' => "Basic #{Base64.strict_encode64("#{client_id}:#{client_secret}")}",
            'Content-Type' => 'application/x-www-form-urlencoded'
          }
        )
        .to_return(status: 200, body: access_token_response, headers: { 'Content-Type' => 'application/json' })
    end

    it 'sends a POST request to the Spotify API and returns a hash with access token information' do
      response = subject.call

      expect(response).to eq(JSON.parse(access_token_response))
    end

    it 'sends a POST request to the Spotify API with basic auth' do
      subject.call

      expect(WebMock).to have_requested(:post, access_token_url)
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
    
    context 'when the response has status different to 200' do
      before do
        stub_request(:post, access_token_url)
          .with(
            body: {
              grant_type: 'authorization_code',
              code: authorization_code,
              redirect_uri: spotify_redirect_uri
            },
            headers: {
              'Authorization' => "Basic #{Base64.strict_encode64("#{client_id}:#{client_secret}")}",
              'Content-Type' => 'application/x-www-form-urlencoded'
            }
          )
          .to_return(status: 430, body: {'body' => 'body'}.to_json, headers: { 'Content-Type' => 'application/json' })
      end
      
      it 'raises Spotify::ApiError' do
        expect { subject.call }.to raise_error(Spotify::OauthError)
      end
    end
  end
end
