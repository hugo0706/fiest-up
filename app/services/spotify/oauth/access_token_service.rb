# frozen_string_literal: true

module Spotify
  module Oauth
    class AccessTokenService < Base
      attr_accessor :code

      def initialize(code)
        self.code = code
      end

      def call
        response = conn.post("api/token", access_token_params)
        case response.status
        when 200
          JSON.parse(response.body)
        else
          raise_error(response)
        end
      rescue Faraday::Error => e
        raise Spotify::OauthError
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
