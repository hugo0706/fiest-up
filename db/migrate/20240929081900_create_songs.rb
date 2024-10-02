# frozen_string_literal: true

class CreateSongs < ActiveRecord::Migration[7.2]
  def change
    create_table :songs do |t|
      t.string :spotify_song_id, null: false, index: { unique: true }
      t.string :name, null: false

      t.timestamps
    end
  end
end
