# frozen_string_literal: true

module Spotify
  module Api
    module Playback
      class CurrentlyPlayingService < Base
        include RetriableRequest

        def call
          response = with_retries(on: [ 404, 500 ], times: 3)  do
            conn.get("me/player/currently-playing")
          end

          case response.status
          when 200
            JSON.parse(response.body)
          when 204
            {}
          when 401
            raise_error("Bad or expired token", response)
          else
            raise_error(response)
          end
        rescue Faraday::Error => e
          raise Spotify::ApiError
        end
      end
    end
  end
end
