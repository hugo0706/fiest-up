# frozen_string_literal: true

module Spotify
  module Api
    module Playback
      class TransferPlaybackService < Base
        include RetriableRequest

        attr_accessor :device_id

        def initialize(access_token, device_id)
          self.device_id = device_id
          super(access_token)
        end

        def call
          response = with_retries(on: [ 404, 500 ], times: 3) do
            conn.put("me/player", transfer_playback_body)
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

        def transfer_playback_body
          {
            device_ids: [ device_id ],
            play: true
          }.to_json
        end
      end
    end
  end
end
