# frozen_string_literal: true

class UserFetcherService
  attr_accessor :code
  include ErrorHandler
  
  class Error < StandardError; end
  
  def initialize(code)
    self.code = code
  end

  def call
    @user_profile = Spotify::Api::CurrentProfileService.new(oauth_data["access_token"]).call
    user = get_registered_user

    return user if user.present?

    UserCreatorService.new(user_info).call
  rescue Spotify::ApiError, Spotify::OauthError => e
    report_error(e)
    raise Error
  end

  private

  def oauth_data
    @oauth_data ||= Spotify::Oauth::AccessTokenService.new(code).call
  end

  def get_registered_user
    spotify_id = @user_profile["id"]
    User.find_by(spotify_id: spotify_id)
  end

  def user_info
    {
      spotify_id: @user_profile["id"],
      email: @user_profile["email"],
      username: @user_profile["display_name"],
      profile_url: @user_profile["external_urls"]["spotify"],
      product: @user_profile["product"],
      access_token: oauth_data["access_token"],
      refresh_token: oauth_data["refresh_token"],
      access_token_expires_at: Time.now + oauth_data["expires_in"]
    }
  end
end
