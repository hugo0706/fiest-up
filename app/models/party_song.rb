# frozen_string_literal: true

class PartySong < ApplicationRecord
  belongs_to :song
  belongs_to :party

  validates :position, uniqueness: { scope: :party_id }
  
  after_create_commit :broadcast_queue_change

  ADD_TO_QUEUE_RETRIES = 3

  def self.add_song_to_queue(party_id:, song_id:)
    retries ||= 0
    max_position = PartySong.where(party_id: party_id).maximum(:position) || 0
    is_first_song = PartySong.where(party_id: party_id, played: false).count == 0
    PartySong.create!(party_id: party_id, song_id: song_id, position: max_position + 1, next_song: is_first_song)
  rescue ActiveRecord::RecordInvalid => e
    if e.record.errors.details[:position].any? { |error| error[:error] == :taken } && retries < ADD_TO_QUEUE_RETRIES
      retries += 1

      retry
    else
      raise e
    end
  end
  
  private 
  
  def broadcast_queue_change
    broadcast_append_later_to "party_#{party.code}_songs", target: "party_songs_list", locals: { song: song, queue_number: party.queue_count - 1 }

    if party.songs.count > 0 && !party.started?
      UpdateCurrentlyPlayingService.new(party: party).call
    end
  end
end
