class AddStartedToParties < ActiveRecord::Migration[7.2]
  def change
    add_column :parties, :started, :boolean, null: false, default: false
  end
end
