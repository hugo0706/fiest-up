# frozen_string_literal: true

module Spotify
  module Oauth
    class AuthorizeService < Base
      USER_SCOPE = %w[user-read-currently-playing user-read-private user-read-email user-read-playback-state user-modify-playback-state]

      attr_accessor :code

      def initialize
      end

      def get_state_and_authorize_url
        url = conn.build_url("authorize", oauth_params)
        return state, url
      end

      private

      def oauth_params
        {
          client_id: CLIENT_ID,
          response_type: "code",
          redirect_uri: SPOTIFY_REDIRECT_URI,
          scope: USER_SCOPE.join(" "),
          state: state
        }
      end

      def state
        @state ||= SecureRandom.hex(16)
      end
    end
  end
end
