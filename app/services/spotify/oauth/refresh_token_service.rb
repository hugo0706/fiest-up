# frozen_string_literal: true

module Spotify
  module Oauth
    class RefreshTokenService < Base
      attr_accessor :refresh_token

      class Error < StandardError; end

      def initialize(refresh_token)
        self.refresh_token = refresh_token
      end

      def call
        response = conn.post("api/token", refresh_token_params)
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

      def refresh_token_params
        {
          grant_type: "refresh_token",
          refresh_token: refresh_token
        }
      end
    end
  end
end
