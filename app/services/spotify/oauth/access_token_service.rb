# frozen_string_literal: true

module Spotify
  module Oauth
    class AccessTokenService < Base
      attr_accessor :code

      class Error < StandardError; end

      def initialize(code)
        self.code = code
      end

      def request_access_token
        response = conn.post("api/token", access_token_params)
        JSON.parse(response.body)
      rescue Faraday::Error,
             Faraday::ServerError => e
        raise Error, e
      end

      private

      def conn
        super.tap do |f|
          f.request :authorization, :basic, CLIENT_ID, CLIENT_SECRET
          f.response :raise_error
        end
      end

      def access_token_params
        {
          grant_type: "authorization_code",
          code: code,
          redirect_uri: SPOTIFY_REDIRECT_URI
        }
      end
    end
  end
end
