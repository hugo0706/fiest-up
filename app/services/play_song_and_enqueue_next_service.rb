# frozen_string_literal: true

class PlaySongAndEnqueueNextService
  attr_accessor :party_song, :party

  def initialize(party_song:, party:)
    self.party_song = party_song
    self.party = party
  end

  def call
    party_owner = User.find(party.user_id)
    song = party_song.song

    Spotify::Api::Playback::StartService.new(party_owner.access_token, party.device_id, song.uri).call
    party_song.update(next_song: false, is_playing: true, played: true)
    
    PlayNextSongJob.set(wait: playing_song_countdown(song)).perform_later(current_party_song: party_song)
    UpdateCurrentlyPlayingService.new(party: party).call
  end
  
  private
  
  def playing_song_countdown(song)
    song.duration / 1000 - 3.seconds
  end
end
