class AddUniqueIndexToPartyUsers < ActiveRecord::Migration[7.2]
  def change
    add_index :party_users, [:party_id, :user_id], unique: true
  end
end
