class AddStoppedToParties < ActiveRecord::Migration[7.2]
  def change
    add_column :parties, :stopped, :boolean, default: false, null: false
  end
end
