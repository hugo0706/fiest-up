# frozen_string_literal: true

class PlayNextSongJob < ApplicationJob
  def perform(current_party_song:, next_party_song:, party:)
    current_party_song.update(is_playing: false)
    PlaySongAndEnqueueNextService.new(party_song: next_party_song, party: party).call
  rescue => e
    report_error(e)
  end
end


