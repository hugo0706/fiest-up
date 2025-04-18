# frozen_string_literal: true

require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Spotify::Api::Base do
  subject { described_class.new(access_token) }

  let(:access_token) { 'mock_access_token' }

  describe '#conn' do
    subject { described_class.new(access_token) }

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
        .with(headers: { 'Authorization' => "Bearer #{access_token}" })
    end
  end

  describe '#api_url' do
    it 'returns the Spotify web API url' do
      url = subject.send(:api_url)
      expect(url).to eq('https://api.spotify.com/v1')
    end
  end
end
