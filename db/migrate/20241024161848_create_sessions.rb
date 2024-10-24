class CreateSessions < ActiveRecord::Migration[7.2]
  def change
    create_table :sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :session_token, null: false, index: { unique: true }
      t.text :data
      t.datetime :expires_at, null: false
      t.string :ip_address
      t.string :user_agent
      t.boolean :expired, default: false
      t.datetime :logout_at

      t.timestamps
    end
  end
end
