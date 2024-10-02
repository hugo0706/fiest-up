FactoryBot.define do
  factory :party_song do
    song { nil }
    party { nil }
    is_playing { false }
    position { 1 }
  end
end
