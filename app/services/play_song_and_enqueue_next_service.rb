# frozen_string_literal: true

class PlaySongAndEnqueueNextService
  attr_accessor :party_song, :party
  
  NEXT_SONG_MARGIN = 3.seconds

  def initialize(party_song:, party:)
    self.party_song = party_song
    self.party = party
  end

  def call
    song = party_song.song

    Spotify::Api::Playback::StartService.new(party.user.access_token, party.device_id, song.uri).call
    party_song.update(next_song: false, is_playing: true, played: true)
    next_party_song.update(next_song: true) if next_party_song.present?
    remove_next_song_job
    job = PlayNextSongJob.set(wait: playing_song_countdown(song)).perform_later(current_party_song: party_song)
    party.update(next_song_job_id: job.provider_job_id)
    UpdateCurrentlyPlayingService.new(party: party).call
    RemoveFirstFromQueueService.new(party: party, party_song_id: party_song.id).call
  end
  
  private
  
  def playing_song_countdown(song)
    song.duration / 1000 - NEXT_SONG_MARGIN
  end
  
  def remove_next_song_job
    if party.next_song_job_id
      SolidQueue::Job.find_by(id: party.next_song_job_id).destroy
    end
  end
  
  def next_party_song
    @next_party_song ||= @party.party_songs.where(played: false)
                                            .order(:position)
                                            .limit(1).first
  end
end
