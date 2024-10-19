# frozen_string_literal: true

class UpdateCurrentlyPlayingService
  attr_accessor :party

  def initialize(party:)
    self.party = party
  end

  def call
    Turbo::StreamsChannel.broadcast_replace_later_to "party_#{party.code}_songs", target: "currently_playing", partial: "parties/currently_playing", locals: { party: party }
  end
end
