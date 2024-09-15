# frozen_string_literal: true

class CreateParties < ActiveRecord::Migration[7.2]
  def change
    create_table :parties do |t|
      t.string :code, null: false, index: { unique: true }
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false

      t.timestamps
    end

    add_index :parties, [ :user_id, :name ], unique: true
  end
end
