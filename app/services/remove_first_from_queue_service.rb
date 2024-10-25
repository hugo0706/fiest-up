# frozen_string_literal: true

class RemoveFirstFromQueueService
  attr_accessor :party, :party_song_id

  def initialize(party:, party_song_id:)
    self.party = party
    self.party_song_id = party_song_id
  end

  def call
    Turbo::StreamsChannel.broadcast_remove_to "party_#{party.code}_guest", target: "party_song_#{party_song_id}"
    Turbo::StreamsChannel.broadcast_remove_to "party_#{party.code}_owner", target: "party_song_#{party_song_id}"
  end
end
