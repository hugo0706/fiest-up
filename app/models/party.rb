# frozen_string_literal: true

class Party < ApplicationRecord
  belongs_to :user
  has_many :party_users, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :code, presence: true, uniqueness: true
end
