class AddDeviceToParty < ActiveRecord::Migration[7.2]
  def change
    add_column :parties, :device_id, :string
  end
end
