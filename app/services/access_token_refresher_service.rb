# frozen_string_literal: true

class AccessTokenRefresherService
  attr_accessor :user_id

  class RefreshTokenError < StandardError; end

  def initialize(user_id)
    self.user_id = user_id
  end

  def call
    user = User.find(user_id)
    oauth_data = Spotify::Oauth::RefreshTokenService.new(user.refresh_token).call

    refresh_in = (oauth_data["expires_in"].to_i * 0.9).seconds

    user.update!(access_token: oauth_data["access_token"])
    RefreshAccessTokenJob.set(wait: refresh_in).perform_later(user_id)
  rescue ActiveRecord::RecordInvalid,
    ActiveRecord::RecordNotFound => e
    raise RefreshTokenError, "Database error: #{e.message}"
  rescue Spotify::Oauth::RefreshTokenService::Error => e
    raise RefreshTokenError, "There was an error with Spotify's api"
  end
end
