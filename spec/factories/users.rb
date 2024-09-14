# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    access_token { SecureRandom.hex(64) }
    spotify_id { SecureRandom.uuid }
    refresh_token { SecureRandom.hex(64) }
    access_token_expires_at { 1.hour.from_now }
    created_at { Time.now }
    updated_at { Time.now }
  end
end
