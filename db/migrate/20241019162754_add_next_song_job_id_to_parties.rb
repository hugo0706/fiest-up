class AddNextSongJobIdToParties < ActiveRecord::Migration[7.2]
  def change
    add_column :parties, :next_song_job_id, :integer
  end
end
