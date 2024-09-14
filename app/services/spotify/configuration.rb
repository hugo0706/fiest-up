# frozen_string_literal: true

module Spotify
  class Configuration
    API_VERSION = "v1"
    BASE_URL = "https://api.spotify.com/#{API_VERSION}"
    ACCOUNTS_URL = "https://accounts.spotify.com/"

    def self.api_version
      API_VERSION
    end

    def self.accounts_url
      ACCOUNTS_URL
    end

    def self.base_url
      BASE_URL
    end
  end
end
