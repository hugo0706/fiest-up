class AddEndsAtAndEndedAtToParties < ActiveRecord::Migration[7.2]
  def change
    add_column :parties, :ends_at, :datetime, null: false
    add_column :parties, :ended_at, :datetime
  end
end
