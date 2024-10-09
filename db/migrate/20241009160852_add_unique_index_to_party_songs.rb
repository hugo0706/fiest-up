# frozen_string_literal: true

class AddUniqueIndexToPartySongs < ActiveRecord::Migration[7.2]
  def change
    add_index :party_songs, [ :party_id, :position ], unique: true
  end
end
