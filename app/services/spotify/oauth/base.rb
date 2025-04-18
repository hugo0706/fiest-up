# frozen_string_literal: true

module Spotify
  module Oauth
    class Base
      CLIENT_ID = ENV["SPOTIFY_CLIENT_ID"]
      CLIENT_SECRET = ENV["SPOTIFY_CLIENT_SECRET"]
      SPOTIFY_REDIRECT_URI = ENV["SPOTIFY_REDIRECT_URI"]

      private

      def accounts_url
        Spotify::Configuration.accounts_url
      end

      def conn
        Faraday.new(connection_options) do |f|
          f.request :url_encoded
        end
      end

      def connection_options
        {
          url: accounts_url,
          request: {
              open_timeout: 7,
              timeout: 7
            }
        }
      end

      def raise_error(message = "Spotify OAuth error", response)
        raise Spotify::OauthError.new(message: message, body: response.body, status: response.status)
      end
    end
  end
end
