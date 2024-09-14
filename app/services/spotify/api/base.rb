# frozen_string_literal: true

module Spotify
  module Api
    class Base
      attr_accessor :oauth_data

      def initialize(oauth_data)
        self.oauth_data = oauth_data
      end

      private

      def api_url
        Spotify::Configuration.base_url
      end

      def conn
        Faraday.new(connection_options) do |f|
          f.request :authorization, "Bearer", -> { oauth_data["access_token"] }
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
    end
  end
end
