# frozen_string_literal: true

module Spotify
  module Api
    class AvailableDevicesService < Base
      class Error < StandardError; end

      def call
        response = conn.get("me/player/devices")

        JSON.parse(response.body)
        #TODO: when receive 401, refresh token?
      rescue Faraday::Error,
             Faraday::ServerError => e
        raise Error, e
      end
    end
  end
end
