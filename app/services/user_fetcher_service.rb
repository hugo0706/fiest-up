class UserFetcherService
  attr_accessor :code
  #TODO: Refactor this, mixes spotify api with business logic
  def initialize(code)
    self.code = code
  end

  def call
    set_current_user_profile
    user = registered_user

    return user if user.present?

    create_user
  end

  private

  def registered_user
    spotify_id = @user_profile_data['id']
    user = User.find_by(spotify_id: spotify_id)
    user
  end

  def set_current_user_profile
    response = conn.get('me')
    @user_profile_data = JSON.parse(response.body)
  end

  def oauth_data
    @oauth_data ||= Spotify::Oauth::AccessTokenService.new(code).request_access_token
  end

  def conn
    Faraday.new(connection_options) do |f|
      f.request :authorization, 'Bearer', -> { oauth_data['access_token'] }
    end
  end

  def connection_options
    {
      url: api_url,
      request: {
          open_timeout: 7,
          timeout: 7
        }
    }
  end

  def api_url
    Spotify::Configuration.base_url
  end

  def create_user
    User.create(user_info)
  end

  def user_info
    {
      spotify_id: @user_profile_data['id'],
      access_token: oauth_data['access_token'],
      refresh_token: oauth_data['refresh_token'],
      access_token_expires_at: Time.now + oauth_data['expires_in']
    }
  end
end
