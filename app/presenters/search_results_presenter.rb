# frozen_string_literal: true

class SearchResultsPresenter
  attr_accessor :data

  def initialize(data)
    @data = data
  end


  def as_json
    {
      spotify_song_id: data["id"],
      name: data["name"],
      artists: data["artists"].map { |artist| artist["name"] },
      image: data.dig("album", "images").min_by { |image| image["height"] }["url"]
    }
  end
end
