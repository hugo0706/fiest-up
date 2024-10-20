# frozen_string_literal: true

class FindOrCreateSongService
  attr_accessor :spotify_song_id, :party_owner

  def initialize(spotify_song_id:, party_owner:)
    self.spotify_song_id = spotify_song_id
    self.party_owner = party_owner
  end

  def call
    song = Spotify::Api::TrackService.new(party_owner.access_token).call(spotify_song_id)
    parsed_song = SearchResultsPresenter.new(song).as_json

    song = Song.find_or_create_by!(spotify_song_id: parsed_song[:spotify_song_id]) do |s|
      s.name = parsed_song[:name].strip
      s.artists = parsed_song[:artists]
      s.image = parsed_song[:image]
      s.uri = parsed_song[:uri]
      s.duration = parsed_song[:duration]
    end
    
    song
  end
end
