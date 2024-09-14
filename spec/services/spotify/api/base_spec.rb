# frozen_string_literal: true

require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Spotify::Api::Base do
  subject { described_class.new(oauth_data) }

  let(:oauth_data) {
    {
      "access_token" => "mock_access_token",
      "token_type" => "Bearer",
      "expires_in" => 3600,
      "refresh_token" => "mock_refresh_token",
      "scope" => "user-read-private user-read-email"
    }
  }

  describe '#conn' do
    subject { described_class.new(oauth_data) }

    it 'returns a Faraday connection with correct settings' do
      connection = subject.send(:conn)
      expect(connection).to be_a(Faraday::Connection)
      expect(connection.options.timeout).to eq(7)
      expect(connection.options.open_timeout).to eq(7)
    end

    it 'sends request with bearer authentication' do
      connection = subject.send(:conn)
      stub_request(:get, 'https://api.spotify.com/v1')
      connection.get('')
      expect(WebMock).to have_requested(:get, 'https://api.spotify.com/v1')
        .with(headers: { 'Authorization' => "Bearer #{oauth_data['access_token']}" })
    end
  end

  describe '#api_url' do
    it 'returns the Spotify web API url' do
      url = subject.send(:api_url)
      expect(url).to eq('https://api.spotify.com/v1')
    end
  end
end
