# frozen_string_literal: true

FactoryBot.define do
  factory :party_user do
    user { nil }
    name { "MyString" }
    party { nil }
  end
end
