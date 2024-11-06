# frozen_string_literal: true

class PlayNextSongJob < ApplicationJob
  def perform(current_party_song:)
    @party = current_party_song.party
    unless @party.ended?
      if @party.next_party_song.present? && !@party.stopped?
        current_party_song.update(is_playing: false)
        PlaySongAndEnqueueNextService.new(party_song: @party.next_party_song, party: @party).call
      else
        @party.update(stopped: true)
        UpdateCurrentlyPlayingService.new(party: @party).call
      end
    end
  rescue => e
    report_error(e)
  end
end
