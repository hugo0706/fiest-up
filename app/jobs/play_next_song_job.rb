# frozen_string_literal: true

class PlayNextSongJob < ApplicationJob
  def perform(current_party_song:)
    @party = current_party_song.party
    current_party_song.update(is_playing: false)

    if next_party_song.present? && !@party.stopped?
      PlaySongAndEnqueueNextService.new(party_song: next_party_song, party: @party).call
    else
      @party.update(stopped: true)
      UpdateCurrentlyPlayingService.new(party: @party).call
    end
  rescue => e
    report_error(e)
  end

  private

  def next_party_song
    @next_party_song ||= @party.party_songs.where(next_song: true).first
  end
end
