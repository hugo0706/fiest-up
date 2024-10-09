# frozen_string_literal: true

FactoryBot.define do
  factory :party_song do
    is_playing { false }
    position { 1 }

    association :party, factory: :party
    association :song, factory: :song
  end
end
