module Spotify
  module Api
    class CurrentProfileService < Base
      def get_current_profile
        response = conn.get("me")
        JSON.parse(response.body)
      end
    end
  end
end
