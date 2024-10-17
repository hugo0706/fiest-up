class AddNextSongToPartySongs < ActiveRecord::Migration[7.2]
  def change
    add_column :party_songs, :next_song, :boolean, null: false, default: false
  end
end
