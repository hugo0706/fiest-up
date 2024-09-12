module Spotify
  module Oauth
    class AccessTokenService < Base
      attr_accessor :code

      def initialize(code)
        self.code = code
      end

      def request_access_token
        response = conn.post("api/token", access_token_params)
        JSON.parse(response.body)
      end

      private

      def conn
        super.tap do |f|
          f.request :authorization, :basic, CLIENT_ID, CLIENT_SECRET
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
