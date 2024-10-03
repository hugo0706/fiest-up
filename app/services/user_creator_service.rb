# frozen_string_literal: true

class UserCreatorService
  attr_accessor :user_info

  class InvalidUserError < StandardError ; end

  def initialize(user_info)
    self.user_info = user_info
  end

  def call
    User.create!(user_info)
  rescue ActiveRecord::RecordInvalid,
        ActiveRecord::RecordNotUnique => e
    raise InvalidUserError, e
  end
end
