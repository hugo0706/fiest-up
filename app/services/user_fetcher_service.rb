class UserFetcherService
  attr_accessor :code

  def initialize(code)
    self.code = code
  end

  def call
    @user_profile = Spotify::Api::CurrentProfileService.new(oauth_data).get_current_profile 
    user = get_registered_user

    return user if user.present?

    create_user
  end

  private

  def oauth_data
    @oauth_data ||= Spotify::Oauth::AccessTokenService.new(code).request_access_token
  end

  def get_registered_user
    spotify_id = @user_profile["id"]
    User.find_by(spotify_id: spotify_id)
  end

  def create_user
    User.create!(user_info)
  end

  def user_info
    {
      spotify_id: @user_profile["id"],
      access_token: oauth_data["access_token"],
      refresh_token: oauth_data["refresh_token"],
      access_token_expires_at: Time.now + oauth_data["expires_in"]
    }
  end
end
