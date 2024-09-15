# frozen_string_literal: true

class CreatePartyUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :party_users do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.string :name, null: false
      t.references :party, null: false, foreign_key: true, index: true

      t.timestamps
    end
  end
end
