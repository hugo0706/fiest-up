class CreateTemporalUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :temporal_users do |t|
      t.string :name

      t.timestamps
    end
  end
end
