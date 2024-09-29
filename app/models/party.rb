# frozen_string_literal: true

class Party < ApplicationRecord
  belongs_to :user
  has_many :party_users, dependent: :destroy
  has_many :temporal_users, through: :party_users, source: :user, source_type: "TemporalUser"
  has_many :users, through: :party_users, source: :user, source_type: "User"

  validates :name, presence: true, uniqueness: { scope: :user_id }, length: { in: 1..15 }
  validates :code, presence: true, uniqueness: true, length: { is: 6 }
  
  after_update_commit -> { broadcast_replace_to "#{code}_currently_playing", target: "currently_playing", partial: "party_data/current_song", locals: { song: 'jeje' } }
end
