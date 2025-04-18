# frozen_string_literal: true

require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Spotify::Api::CurrentProfileService do
  let(:access_token) { "mock_access_token" }

  subject { described_class.new(access_token) }

  describe '#call' do
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
            'Authorization' => "Bearer #{access_token}"
          }
        )
        .to_return(status: 200, body: current_profile_response.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'performs a GET request to Spotify me API endpoint' do
      subject.call

      expect(WebMock).to have_requested(:get, current_profile_url)
        .with(
          headers: {
            'Authorization' => "Bearer #{access_token}"
          }
        )
    end

    it 'it returns the body converted to hash' do
      expect(subject.call).to eq(current_profile_response)
    end

    context 'when Faraday request raises an exception' do
      let(:conn) { double(Faraday::Connection) }

      before { allow(subject).to receive(:conn).and_return(conn) }

      it 'raises Spotify::ApiError' do
        allow(conn).to receive(:get).and_raise(Faraday::Error)
        expect { subject.call }.to raise_error(Spotify::ApiError)
      end
    end

    context 'when the response has status 401' do
      before do
        stub_request(:get, current_profile_url)
          .with(
            headers: {
              'Authorization' => "Bearer #{access_token}"
            }
          )
          .to_return(status: 401, body: { 'body' => 'body' }.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      it 'raises Spotify::ApiError with the response details' do
        expect { subject.call }.to raise_error(Spotify::ApiError) { |error|
            expect(error.message).to eq("Bad or expired token")
            expect(error.body).to eq({ 'body' => 'body' }.to_json)
            expect(error.status).to eq(401)
          }
      end
    end
  end
end
