# frozen_string_literal: true

module Spotify
  module Api
    class AvailableDevicesService < Base
      def call
        response = conn.get("me/player/devices")

        case response.status
        when 200
          JSON.parse(response.body)
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
