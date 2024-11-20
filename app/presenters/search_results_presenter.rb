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
      image: image(data.dig("album", "images")),
      uri: data["uri"],
      duration: data["duration_ms"]
    }
  end
  
  def image(images)
    sorted_images = images.sort_by { |image| image["height"] }
    image = sorted_images.count > 1 ? sorted_images[1] : sorted_images.first
    image["url"]
  end
end
