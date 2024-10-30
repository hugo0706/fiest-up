# frozen_string_literal: true

class User < ApplicationRecord
  validates :spotify_id, presence: true, uniqueness: true
  validates :access_token, :refresh_token, :access_token_expires_at, presence: true
  validates :username, presence: true

  encrypts :access_token
  encrypts :refresh_token

  has_many :parties, dependent: :destroy
  has_many :party_users, as: :user, dependent: :destroy
  has_many :joined_parties, through: :party_users, source: :party
  has_many :sessions, dependent: :destroy
  
  def is_premium?
    self.product == 'premium'
  end
end
