# frozen_string_literal: true

class PlayNextSongJob < ApplicationJob
  def perform(current_party_song:)
    @party = current_party_song.party
    current_party_song.update(is_playing: false)
    if next_party_song.present?
      next_party_song.update(next_song: true)
      PlaySongAndEnqueueNextService.new(party_song: next_party_song, party: @party).call
    else
      @party.update(started: false)
    end
  rescue => e
    report_error(e)
  end
  
  private 
  
  def next_party_song
    @next_party_song ||= @party.party_songs.where(played: false)
                                            .order(:position)
                                            .limit(1).first
  end
end


