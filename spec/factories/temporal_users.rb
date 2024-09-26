# frozen_string_literal: true

require 'ffaker'

FactoryBot.define do
  factory :temporal_user do
    name { FFaker::Name.name[0..12] }
  end
end
