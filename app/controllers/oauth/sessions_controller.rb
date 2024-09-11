module Oauth
  class SessionsController < ApplicationController
    SPOTIFY_CLIENT_ID = ENV["SPOTIFY_CLIENT_ID"]
    SPOTIFY_REDIRECT_URI = ENV["SPOTIFY_REDIRECT_URI"]
    SPOTIFY_ACCOUNTS_URL= "https://accounts.spotify.com/"
    USER_SCOPE = %w[user-read-private user-read-email]

    def login
      auth_url = conn.build_url("authorize")

      redirect_to auth_url, allow_other_host: true
    end

    def callback
      render plain: "logged in", status: :ok
    end

    private

    def conn
      Faraday.new(connection_options) do |f|
        f.request :url_encoded
      end
    end

    def connection_options
      {
        url: SPOTIFY_ACCOUNTS_URL,
        params: oauth_params,
        request: {
            open_timeout: 7,
            timeout: 7
          }
      }
    end

    def oauth_params
      {
        client_id: SPOTIFY_CLIENT_ID,
        response_type: "code",
        redirect_uri: SPOTIFY_REDIRECT_URI,
        scope: USER_SCOPE.join(" "),
        state: SecureRandom.hex(16)
      }
    end
  end
end
