# frozen_string_literal: true

class PartyUser < ApplicationRecord
  belongs_to :user, polymorphic: true
  belongs_to :party

  before_destroy :destroy_temporal_user

  private

  def destroy_temporal_user
    user.destroy if user_type == TemporalUser.name
  end
end
