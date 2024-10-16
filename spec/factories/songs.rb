# frozen_string_literal: true

require 'ffaker'

FactoryBot.define do
  factory :song do
    spotify_song_id { FFaker::PhoneNumber.imei }
    name { FFaker::Name.name }
    image { FFaker::Image.url }
    artists { Array.new(rand(1..4)) { FFaker::Name.name } }
    uri { FFaker::Internet.uri(spotify_song_id) }
    duration {  Random.rand(100000) }
    
  end
end
