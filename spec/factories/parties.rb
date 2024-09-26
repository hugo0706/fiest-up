# frozen_string_literal: true

require 'ffaker'

FactoryBot.define do
  factory :party do
    code { FFaker::Color.hex_code }
    name { FFaker::Name.name[0, 14] }

    association :user, factory: :user
  end
end
