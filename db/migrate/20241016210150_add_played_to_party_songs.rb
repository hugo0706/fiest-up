class AddPlayedToPartySongs < ActiveRecord::Migration[7.2]
  def change
    add_column :party_songs, :played, :boolean, default: false, null: :false
  end
end
