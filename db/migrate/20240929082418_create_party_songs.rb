class CreatePartySongs < ActiveRecord::Migration[7.2]
  def change
    create_table :party_songs do |t|
      t.references :song, null: false, foreign_key: true
      t.references :party, null: false, foreign_key: true
      t.boolean :is_playing, default: false, null: false
      t.integer :position, null: false

      t.timestamps
    end
  end
end
