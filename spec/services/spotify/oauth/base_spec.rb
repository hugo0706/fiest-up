# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spotify::Oauth::Base do
  subject { described_class.new }

  describe '#conn' do
    it 'returns a Faraday connection with correct settings' do
      connection = subject.send(:conn)
      expect(connection).to be_a(Faraday::Connection)
      expect(connection.options.timeout).to eq(7)
      expect(connection.options.open_timeout).to eq(7)
    end
  end

  describe '#accounts_url' do
    it 'returns the Spotify accounts API url' do
      url = subject.send(:accounts_url)
      expect(url).to eq('https://accounts.spotify.com/')
    end
  end
end
