# frozen_string_literal: true

module Spotify
  module Api
    class SearchService < Base
      def call(query)
        response = conn.get("search?q=#{query.gsub(" ","+")}&type=track")

        case response.status
        when 200
          JSON.parse(response.body)["tracks"]["items"]
        when 401
          raise_error("Bad or expired token", response)
        when 403
          raise_error("Bad OAuth request (wrong consumer key, bad nonce, expired timestamp...)", response)
        when 429
          raise_error("Rate limit exceeded", response)
        else
          raise_error(response)
        end
      rescue Faraday::Error => e
        raise Spotify::ApiError
      end
    end
  end
end
