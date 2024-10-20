# frozen_string_literal: true

module Spotify
  module Api
    module Playback
      class StartService < Base
        include RetriableRequest

        attr_accessor :device_id, :uri

        def initialize(access_token, device_id, uri = nil)
          self.device_id = device_id
          self.uri = uri
          super(access_token)
        end

        def call
          response = with_retries(on: [ 404, 500 ], times: 3) do
            conn.put("me/player/play", start_body)
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

        private

        def start_body
          body = {
            device_id: device_id
          }
          body.merge!({ uris: [ uri ] }) if uri
          body.to_json
        end
      end
    end
  end
end
