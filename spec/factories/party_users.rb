# frozen_string_literal: true


FactoryBot.define do
  factory :party_user do
    association :user, factory: :user
    association :party, factory: :party

    trait :temporal_user do
      association :user, factory: :temporal_user
    end
  end
end
