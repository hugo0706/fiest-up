# frozen_string_literal: true

class Party < ApplicationRecord
  MAX_DURATION = 6.hours

  belongs_to :user

  has_many :party_songs, dependent: :destroy
  has_many :songs, through: :party_songs
  has_many :party_users, dependent: :destroy
  has_many :temporal_users, through: :party_users, source: :user, source_type: "TemporalUser"
  has_many :users, through: :party_users, source: :user, source_type: "User"

  validates :name, presence: true, uniqueness: { scope: :user_id }, length: { in: 1..15 }
  validates :code, presence: true, uniqueness: true, length: { is: 6 }

  def currently_playing_song
    party_songs.where(is_playing: true).first&.song
  end

  def currently_playing_party_song
    party_songs.where(is_playing: true).first
  end

  def non_played_songs
    songs.where(party_songs: { played: false })
  end
  
  def next_party_song
    party_songs.where(next_song: true).first || non_played_songs.first
  end

  def has_pending_songs?
    non_played_songs.count > 0
  end

  def queue_count
    non_played_songs.count
  end

  def ended?
    self.ended_at != nil
  end
  
  def end
    self.update(ended_at: Time.now) unless ended?
  end
end
