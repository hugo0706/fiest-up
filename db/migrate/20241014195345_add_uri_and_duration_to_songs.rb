class AddUriAndDurationToSongs < ActiveRecord::Migration[7.2]
  def change
    add_column :songs, :uri, :string, null: false
    add_column :songs, :duration, :integer, null: false
  end
end
