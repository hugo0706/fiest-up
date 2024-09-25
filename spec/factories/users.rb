# frozen_string_literal: true
require 'ffaker'

FactoryBot.define do
  factory :user do
    access_token { SecureRandom.hex(64) }
    spotify_id { SecureRandom.uuid }
    refresh_token { SecureRandom.hex(64) }
    email { FFaker::Internet.email }
    username { FFaker::Name.name}
    product { 'premium' }
    profile_url { FFaker::Internet.http_url }
    access_token_expires_at { 1.hour.from_now }
    created_at { Time.now }
    updated_at { Time.now }
    
    trait :free do
      product { 'free' }
    end
  end
end
