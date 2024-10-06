# frozen_string_literal: true

module Spotify
  module Api
    class Base
      attr_accessor :access_token

      def initialize(access_token)
        self.access_token = access_token
      end

      private

      def api_url
        Spotify::Configuration.base_url
      end

      def conn
        Faraday.new(connection_options) do |f|
          f.request :authorization, "Bearer", -> { access_token }
        end
      end

      def connection_options
        {
          url: api_url,
          request: {
              open_timeout: 7,
              timeout: 7
            }
        }
      end

      def raise_error(message = "Spotify Api error", response)
        raise Spotify::ApiError.new(message: message, body: response.body, status: response.status)
      end
    end
  end
end
