# frozen_string_literal: true

class PartySong < ApplicationRecord
  belongs_to :song
  belongs_to :party
end
