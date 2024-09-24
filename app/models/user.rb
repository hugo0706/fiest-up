# frozen_string_literal: true

class User < ApplicationRecord
  validates :spotify_id, presence: true, uniqueness: true
  validates :access_token, :refresh_token, :access_token_expires_at, presence: true

  encrypts :access_token
  encrypts :refresh_token
  
  has_many :parties, dependent: :destroy
  has_many :party_users, as: :user, dependent: :destroy
end
