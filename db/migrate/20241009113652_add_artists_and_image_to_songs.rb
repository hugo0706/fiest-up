# frozen_string_literal: true

class AddArtistsAndImageToSongs < ActiveRecord::Migration[7.2]
  def change
    add_column :songs, :artists, :string, array: true, default: []
    add_column :songs, :image, :string
  end
end
