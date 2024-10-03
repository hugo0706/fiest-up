# frozen_string_literal: true

class UserCreatorService
  attr_accessor :user_info

  class InvalidUserError < StandardError ; end

  def initialize(user_info)
    self.user_info = user_info
  end

  def call
    user = User.create!(user_info)

    RefreshAccessTokenJob.set(wait_until: user.access_token_expires_at - 5.minutes).perform_later
    user
  rescue ActiveRecord::RecordInvalid,
        ActiveRecord::RecordNotUnique => e
    raise InvalidUserError, e
  end
end
