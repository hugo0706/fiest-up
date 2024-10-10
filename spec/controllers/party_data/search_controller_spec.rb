# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PartyData::SearchController, type: :controller do
  describe "GET #search" do
    let(:search_results) do
      [ {
        "album"=>
        { "album_type"=>"album",
         "artists"=>
          [ { "external_urls"=>{ "spotify"=>"https://open.spotify.com/artist/62SCu33InHVq97VaWw3eof" },
            "href"=>"https://api.spotify.com/v1/artists/62SCu33InHVq97VaWw3eof",
            "id"=>"62SCu33InHVq97VaWw3eof",
            "name"=>"MPH",
            "type"=>"artist",
            "uri"=>"spotify:artist:62SCu33InHVq97VaWw3eof" } ],
         "available_markets"=>[],
         "external_urls"=>{ "spotify"=>"https://open.spotify.com/album/2R2BtdlMg4A44CzaQdmFfa" },
         "href"=>"https://api.spotify.com/v1/albums/2R2BtdlMg4A44CzaQdmFfa",
         "id"=>"2R2BtdlMg4A44CzaQdmFfa",
         "images"=>
          [ { "height"=>640, "url"=>"https://i.scdn.co/image/ab67616d0000b2734a7f4cf67c5f1c07701846e6", "width"=>640 },
           { "height"=>300, "url"=>"https://i.scdn.co/image/ab67616d00001e024a7f4cf67c5f1c07701846e6", "width"=>300 },
           { "height"=>64, "url"=>"https://i.scdn.co/image/ab67616d000048514a7f4cf67c5f1c07701846e6", "width"=>64 } ],
         "name"=>"Refraction",
         "release_date"=>"2024-08-23",
         "release_date_precision"=>"day",
         "total_tracks"=>15,
         "type"=>"album",
         "uri"=>"spotify:album:2R2BtdlMg4A44CzaQdmFfa" },
       "artists"=>
        [ { "external_urls"=>{ "spotify"=>"https://open.spotify.com/artist/62SCu33InHVq97VaWw3eof" },
         "href"=>"https://api.spotify.com/v1/artists/62SCu33InHVq97VaWw3eof",
         "id"=>"62SCu33InHVq97VaWw3eof",
         "name"=>"MPH",
         "type"=>"artist",
         "uri"=>"spotify:artist:62SCu33InHVq97VaWw3eof" } ],
       "available_markets"=>[],
       "disc_number"=>1,
       "duration_ms"=>193185,
       "explicit"=>false,
       "external_ids"=>{ "isrc"=>"CA5KR2475590" },
       "external_urls"=>{ "spotify"=>"https://open.spotify.com/track/6BIxglmdOjzfDqdjokHobF" },
       "href"=>"https://api.spotify.com/v1/tracks/6BIxglmdOjzfDqdjokHobF",
       "id"=>"6BIxglmdOjzfDqdjokHobF",
       "is_local"=>false,
       "name"=>"Lights On",
       "popularity"=>42,
       "preview_url"=>"https://p.scdn.co/mp3-preview/a59acaecde06090b208ac0d10dba3a3733c1de49?cid=3928b8016196469791bba6847ccfadfe",
       "track_number"=>9,
       "type"=>"track",
       "uri"=>"spotify:track:6BIxglmdOjzfDqdjokHobF"
      } ]
    end

    let(:parsed_response) { [ { spotify_song_id: "6BIxglmdOjzfDqdjokHobF", name: "Lights On", artists: [ "MPH" ], image: "https://i.scdn.co/image/ab67616d000048514a7f4cf67c5f1c07701846e6" } ] }

    context "when the party exists and the user is in the party" do
      let(:party) { create(:party) }
      let(:user) { create(:user) }

      before do
        allow_any_instance_of(Spotify::Api::SearchService).to receive(:call).and_return(search_results)
        party.users << user
        session[:user_id] = user.id
      end

      it 'returns the parsed Spotify search results' do
        allow(controller).to receive(:render).and_call_original

        get :search, params: { code: party.code, query: "mph" }

        expect(controller).to have_received(:render).with(partial: 'party_data/search_results', locals: { songs: parsed_songs, party_code: party.code })
      end

      context "when spotify api call raises an error" do
        before { allow_any_instance_of(Spotify::Api::SearchService).to receive(:call).and_raise(Spotify::ApiError) }

        it 'returns an empty json with status 500' do
          get :search, params: { code: party.code, query: "mph" }

          expect(response.body).to eq({}.to_json)
          expect(response.status).to eq(500)
        end
      end
    end

    context "when the party does not exist" do
      it 'returns an json with status not_found' do
        get :search, params: { code: 'code', query: "mph" }

        expect(response.body).to eq({ error: "Party not found" }.to_json)
        expect(response.status).to eq(404)
      end
    end

    context "when the user has not joined the party" do
      let(:party) { create(:party) }
      let(:user) { create(:user) }

      before { session[:user_id] = user.id }

      it 'returns an json with status not_found' do
        get :search, params: { code: party.code, query: "mph" }

        expect(response.body).to eq({ error: "User not in party" }.to_json)
        expect(response.status).to eq(404)
      end
    end
  end
end
