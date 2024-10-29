# frozen_string_literal: true

class PartyEnderJob < ApplicationJob
  def perform(party_id)
    Party.find(party_id).end
  rescue => e
    report_error(e)
  end
end
