# frozen_string_literal: true

module Spotify
  module Api
    class CurrentProfileService < Base
      class Error < StandardError; end

      def current_profile
        response = conn.get("me")
        JSON.parse(response.body)
      rescue Faraday::Error,
             Faraday::ServerError => e
        raise Error, e
      end
    end
  end
end
