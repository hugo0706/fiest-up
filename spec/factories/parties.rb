# frozen_string_literal: true

require 'ffaker'

FactoryBot.define do
  factory :party do
    code { FFaker::Color.hex_code }
    name { FFaker::Name.name[0, 14] }
    device_id { 'device' }
    ends_at { Time.now + Party::MAX_DURATION }

    association :user, factory: :user
  end
end
