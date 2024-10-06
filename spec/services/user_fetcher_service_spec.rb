# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserFetcherService do
  let(:code) { 'code' }
  subject { described_class.new(code) }

  describe '#call' do
    let(:spotify_id) { 'spotify_id' }
    let(:access_token_data) do
      {
        "access_token" => "mock_access_token",
        "token_type" => "Bearer",
        "expires_in" => 3600,
        "refresh_token" => "mock_refresh_token",
        "scope" => "user-read-private user-read-email"
      }
    end
    let(:current_profile_data) {
      {
       "display_name"=>"user",
       "external_urls"=>{ "spotify"=>"https://open.spotify.com/user/username" },
       "href"=>"https://api.spotify.com/v1/users/username",
       "id"=> spotify_id,
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
      current_profile_service_double = double(Spotify::Api::CurrentProfileService)

      allow_any_instance_of(Spotify::Oauth::AccessTokenService).to receive(:call)
        .and_return(access_token_data)
      expect(Spotify::Api::CurrentProfileService).to receive(:new).with(access_token_data["access_token"])
        .and_return(current_profile_service_double)
      allow(current_profile_service_double).to receive(:call)
        .and_return(current_profile_data)
    end

    context 'when the user already exists in database' do
      let!(:existing_user) { create(:user, spotify_id: spotify_id) }

      it 'returns the existing user' do
        result = nil
        expect { result = subject.call }.to not_change { User.count }
        expect(result).to eq(existing_user)
      end
    end

    context 'when the user does not exist in database' do
      let(:user_info) do
        {
          spotify_id: current_profile_data["id"],
          email: current_profile_data["email"],
          username: current_profile_data["display_name"],
          profile_url: current_profile_data["external_urls"]["spotify"],
          product: current_profile_data["product"],
          access_token: access_token_data["access_token"],
          refresh_token: access_token_data["refresh_token"],
          access_token_expires_at: Time.now + access_token_data["expires_in"]
        }
      end
      
      it 'calls UserCreatorService with user_info' do
        Timecop.freeze(Time.now) do
          expect(UserCreatorService).to receive(:new).with(user_info).and_call_original
          subject.call
        end
      end
    end
  end
end
