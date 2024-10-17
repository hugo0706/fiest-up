# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spotify::Oauth::AuthorizeService do
  describe "#get_state_and_authorize_url" do
    let(:client_id) { 'client_id' }
    let(:spotify_redirect_uri) { 'http://spotify.com' }
    let(:state) { 'state' }
    let(:user_scopes) { %w[user-read-currently-playing user-read-private user-read-email user-read-playback-state user-modify-playback-state] }

    before do
      stub_const('Spotify::Oauth::AuthorizeService::CLIENT_ID', client_id)
      stub_const('Spotify::Oauth::AuthorizeService::SPOTIFY_REDIRECT_URI', spotify_redirect_uri)
      allow(SecureRandom).to receive(:hex).with(16).and_return(state)
    end

    it 'returns the state value and the url to redirect the user' do
      result = subject.get_state_and_authorize_url

      expect([ result.first, result.second.to_s ]).to eq([ state,
                                                        "https://accounts.spotify.com/authorize?" \
                                                          "client_id=#{client_id}" \
                                                          "&redirect_uri=#{CGI.escape(spotify_redirect_uri)}" \
                                                          "&response_type=code" \
                                                          "&scope=#{user_scopes.join('+')}" \
                                                          "&state=#{state}" ]
                                                      )
    end
  end
end
