# frozen_string_literal: true

require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Spotify::Api::CurrentProfileService do
  let(:oauth_data) {
    {
      "access_token" => "mock_access_token",
      "token_type" => "Bearer",
      "expires_in" => 3600,
      "refresh_token" => "mock_refresh_token",
      "scope" => "user-read-private user-read-email"
    }
  }

  subject { described_class.new(oauth_data) }

  describe '#get_current_profile' do
    let(:current_profile_url) { 'https://api.spotify.com/v1/me' }
    let(:current_profile_response) {
      {
       "display_name"=>"user",
       "external_urls"=>{ "spotify"=>"https://open.spotify.com/user/username" },
       "href"=>"https://api.spotify.com/v1/users/username",
       "id"=> 'spotify_id',
       "images"=>[ { "url"=>"https://i.scdn.co/image/ab6775asdqafsdfsdf0fb14b061a790d", "height"=>64, "width"=>64 }, { "url"=>"https://i.scdn.co/image/ab677570asdasdqf24fdg0fb14b061a790d", "height"=>300, "width"=>300 } ],
       "type"=>"user",
       "uri"=>"spotify:user:username",
       "followers"=>{ "href"=>nil, "total"=>20 },
       "country"=>"ES",
       "product"=>"premium",
       "explicit_content"=>{ "filter_enabled"=>false, "filter_locked"=>false },
       "email"=>"user@mail.com"
      }
    }

    before do
      stub_request(:get, current_profile_url)
        .with(
          headers: {
            'Authorization' => "Bearer #{oauth_data["access_token"]}"
          }
        )
        .to_return(status: 200, body: current_profile_response.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'performs a GET request to Spotify me API endpoint' do
      subject.get_current_profile

      expect(WebMock).to have_requested(:get, current_profile_url)
        .with(
          headers: {
            'Authorization' => "Bearer #{oauth_data["access_token"]}"
          }
        )
    end

    it 'it returns the body converted to hash' do
      expect(subject.get_current_profile).to eq(current_profile_response)
    end
  end
end
