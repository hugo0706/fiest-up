# frozen_string_literal: true

class SessionCreatorService
  attr_accessor :user

  SESSION_CREATION_RETRIES = 3

  class RetriesDepleted < StandardError; end

  def initialize(user)
    self.user = user
  end

  def call
    retries = 0
    session = nil

    loop do
      raise RetriesDepleted if retries >= SESSION_CREATION_RETRIES
      session_token = SecureRandom.hex(25)
      session = Session.create(user: user, session_token: session_token, expires_at: Time.now + 3.days)
      break if session.valid?
      retries += 1
    end

    session.session_token
  end
end
