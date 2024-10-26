# frozen_string_literal: true

class TemporalUser < ApplicationRecord
  has_one :party_user, as: :user, dependent: :destroy
  has_one :party, through: :party_user, source: :party

  validates :name, presence: true, length: { in: 1..13 }
end
