# frozen_string_literal: true

class Song < ApplicationRecord
  has_many :party_songs, dependent: :destroy
  has_many :parties, through: :party_songs

  validates :spotify_song_id, presence: true, uniqueness: true
end
