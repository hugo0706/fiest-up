# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :access_token, null: false, limit: 510
      t.string :spotify_id, null: false, index: { unique: true }
      t.string :refresh_token, null: false, limit: 510
      t.string :email, null: false
      t.string :username, null: false
      t.string :product, null: false
      t.string :profile_url, null: false
      t.datetime :access_token_expires_at, null: false

      t.timestamps
    end
  end
end
